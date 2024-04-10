#include "fileinfo.h"
#include <QPainter>
#include <qfileinfo.h>
#include <qdebug.h>
#include <qqmlengine.h>
#include <QtConcurrent/qtconcurrentrun.h>
#include <QTimer>

FileInfo::FileInfo(QObject* parent)
	: QObject(parent)
{
	m_videoStreams = new ListViewModel(VideoInfo::staticMetaObject, this);
	m_audioStreams = new ListViewModel(AudioInfo::staticMetaObject, this);
	m_subtitleStreams = new ListViewModel(SubtitleInfo::staticMetaObject, this);
	m_outFileInfo = new OutFileInfo();
	m_command = new FFmpegCommand(this);
}

FileInfo::~FileInfo()
{
	delete m_videoStreams;
	m_videoStreams = nullptr;

	delete m_audioStreams;
	m_audioStreams = nullptr;

	delete m_subtitleStreams;
	m_subtitleStreams = nullptr;
}

QString FileInfo::completeName() const
{
	return m_completeName;
}

QString FileInfo::fileName() const
{
	return m_fileName;
}

bool FileInfo::frameToImage(AVFrame* frame)
{
	if (frame->width > 0 && frame->height > 0)
	{
		m_thumbnail = QImage(frame->width, frame->height, QImage::Format_RGB555);

		int dstStride[1] = { m_thumbnail.bytesPerLine() };
		uint8_t* const dst[1] = { new uint8_t[dstStride[0]* m_thumbnail.height()*2]};	
	
		auto img_convert_ctx = sws_getContext(frame->width, frame->height, (AVPixelFormat)frame->format,
			frame->width, frame->height, AVPixelFormat::AV_PIX_FMT_RGB555LE,
			SWS_BICUBIC, NULL, NULL, NULL);

		auto result = sws_scale(img_convert_ctx, frame->data, frame->linesize, 0, frame->height, dst, dstStride);

		sws_freeContext(img_convert_ctx);
		memcpy(m_thumbnail.bits(), dst[0], m_thumbnail.bytesPerLine() * m_thumbnail.height());
		delete dst[0];
		//m_thumbnail.loadFromData(dst[0], m_thumbnail.bytesPerLine() * m_thumbnail.height(), QImage::Format_RGB555);
		return true;
	}
	return false;
}

bool getFormatContextFromat(AVFormatContext* context, int stream_index, double timestamp, AVFrame* frame)
{
	int64_t dts;
	int64_t wall;
	av_get_output_timestamp(context, stream_index, &dts, &wall);

	auto stream = context->streams[stream_index];

	auto avctx = avcodec_alloc_context3(NULL);

	auto ret = avcodec_parameters_to_context(avctx, stream->codecpar);

	avctx->pkt_timebase = stream->time_base;

	auto codec = avcodec_find_decoder(avctx->codec_id);

	if (codec == nullptr)
	{
		avcodec_free_context(&avctx);
		return false;
	}
	avctx->codec_id = codec->id;

	AVDictionary* dictionary = nullptr;
	ret = avcodec_open2(avctx, codec, &dictionary);

	auto pack = av_packet_alloc();
	av_seek_frame(context, -1, timestamp * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);

	while (av_read_frame(context, pack) >= 0)
	{
		if (pack->stream_index == stream_index)
		{
			ret = avcodec_send_packet(avctx, pack);

			if (avcodec_receive_frame(avctx, frame) >= 0)
			{
				break;
			}
		}
	}
	av_free_packet(pack);
	avcodec_free_context(&avctx);
	return true;
}

void FileInfo::setCompleteName(const QString& newCompleteName)
{
	if (m_completeName == newCompleteName)
		return;
	m_completeName = newCompleteName;
	m_videoStreams->clear();
	m_audioStreams->clear();
	m_subtitleStreams->clear();

	if (QFileInfo::exists(m_completeName))
	{
		QFileInfo fileInfo(m_completeName);

		m_fileName = fileInfo.fileName();
		this->m_fileSize = fileInfo.size();
		if (m_fileSize == 0)
		{
			return;
		}
		auto ic = avformat_alloc_context();
		AVDictionary* options = nullptr;
		auto err = avformat_open_input(&ic, m_completeName.toUtf8(), nullptr, &options);
		if (err >= 0)
		{
			avformat_find_stream_info(ic, nullptr);
			AVDictionaryEntry* dictionaryEntry = nullptr;
			while (dictionaryEntry = av_dict_get(ic->metadata, "", dictionaryEntry, AV_DICT_IGNORE_SUFFIX))
			{
                qDebug()<<dictionaryEntry->key<<":"<<dictionaryEntry->value;
				if (strcmp(dictionaryEntry->key, "encoder") == 0)
				{
					m_encoder = QString::fromUtf8(dictionaryEntry->value);
				}
				if (strcmp(dictionaryEntry->key, "creation_time") == 0)
				{
					m_creation_time = QString::fromUtf8(dictionaryEntry->value);
				}
			}
            if ( ic->duration != AV_NOPTS_VALUE)
            {
                    this->m_duration = ic->duration / AV_TIME_BASE;
            }

			this->m_format = fileInfo.suffix();// QString::fromUtf8(ic->iformat->name);
			m_overallBitRate = ic->bit_rate;

			for (int i = 0; i < ic->nb_streams; i++)
			{
				auto stream = ic->streams[i];

				switch (stream->codec->codec_type)
				{
				case AVMEDIA_TYPE_AUDIO:
				{
					auto audioInfo = new AudioInfo(stream, this);
					m_audioStreams->append(audioInfo);
				}
				break;
				case AVMEDIA_TYPE_SUBTITLE:
					m_subtitleStreams->append(new SubtitleInfo(stream, this));
					break;
				case AVMEDIA_TYPE_VIDEO:
					m_videoStreams->append(new VideoInfo(stream, this));
					break;
				}
			}

			if (m_videoStreams->size() > 0)
			{
				auto videoInfo = static_cast<VideoInfo*>(m_videoStreams->at(0));
				auto frame = av_frame_alloc();
				if (getFormatContextFromat(ic, videoInfo->id(), videoInfo->duration() > 10 ? 10 : 0, frame))
				{
					frameToImage(frame);
				}
				av_frame_free(&frame);
                //avformat_free_context(ic);
                avformat_close_input(&ic);

			}
			else {
                avformat_close_input(&ic);
			}
			emit completeNameChanged();
		}
		else
		{
            avformat_close_input(&ic);
		}
	}
	
}

QString FileInfo::format() const
{
	return m_format;
}

QString FileInfo::formatVersion() const
{
	return m_formatVersion;
}

double FileInfo::fileSize() const
{
	return m_fileSize;
}

double FileInfo::duration() const
{
	return m_duration;
}

double FileInfo::overallBitRate() const
{
	return m_overallBitRate;
}

double FileInfo::encodedDate() const
{
	return m_encodedDate;
}

ListViewModel* FileInfo::videoStreams() const
{
	return m_videoStreams;
}

ListViewModel* FileInfo::audioStreams() const
{
	return m_audioStreams;
}

ListViewModel* FileInfo::subtitleStreams() const
{
	return m_subtitleStreams;
}

QString FileInfo::encoder() const
{
	return m_encoder;
}

QString FileInfo::creation_time() const
{
	return m_creation_time;
}


QImage FileInfo::thumbnail() const
{
	return m_thumbnail;
}

OutFileInfo* FileInfo::outFileInfo() const
{
	return m_outFileInfo;
}

bool FileInfo::checked() const
{
	return m_checked;
}

void FileInfo::setChecked(bool newChecked)
{
	if (m_checked == newChecked)
		return;
	m_checked = newChecked;
	emit checkedChanged();
}

FFmpegCommand* FileInfo::command() const
{
	return m_command;
}

QString FileInfo::convert() const
{
	return m_convert;
}

void FileInfo::setConvert(const QString& newConvert)
{
	if (m_convert == newConvert)
		return;
	m_convert = newConvert;
	emit completeNameChanged();
}
