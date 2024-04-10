#include "mediastreaminfo.h"

MediaStreamInfo::MediaStreamInfo(const AVStream* stream, QObject* parent)
	: QObject{ parent }
{	
	m_id = stream->index;
	if (stream->duration != AV_NOPTS_VALUE)
	{
		m_duration = stream->duration * av_q2d(stream->time_base);
	}	
	if (stream->codec->bit_rate != 0)
	{
		m_bit_rate = stream->codec->bit_rate;
	}
	auto codecnmae = avcodec_get_name(stream->codecpar->codec_id);
	m_codecId = QString::fromUtf8(codecnmae);	

	m_metadata = new ListViewModel(Metadata::staticMetaObject, this);
	AVDictionaryEntry* dic = nullptr;
	while (dic = av_dict_get(stream->metadata, "", dic, AV_DICT_IGNORE_SUFFIX))
	{		
		auto data = new Metadata(dic->key, dic->value);
		if (data->key() == "DURATION"|| data->key() == "DURATION-eng")
		{
			auto hsm = data->value().trimmed().split(":");

			m_duration = hsm[0].toInt() * 60 * 60 + hsm[1].toInt() * 60 + hsm[2].toDouble();
			delete data;
		
		}
		else if (data->key() == "BPS"|| data->key() == "BPS-eng")//BPS
		{
			m_bit_rate = data->value().trimmed().toInt();
			delete data;
		}
		else if (data->key() == "NUMBER_OF_BYTES"|| data->key() == "NUMBER_OF_BYTES-eng")
		{			
			m_streamSize = data->value().trimmed().toDouble();
			delete data;
		}
		else
		{
			m_metadata->append(data);
		}
	
	}
}
MediaStreamInfo::~MediaStreamInfo()
{
	m_metadata->clear();
}
int MediaStreamInfo::id() const
{
	return m_id;
}

QString MediaStreamInfo::format() const
{
	return m_format;
}

QString MediaStreamInfo::codecId() const
{
	return m_codecId;
}

double MediaStreamInfo::duration() const
{
	return m_duration;
}

double MediaStreamInfo::streamSize() const
{
	return m_streamSize;
}

QString MediaStreamInfo::formatInfo() const
{
	return m_formatInfo;
}

ListViewModel *MediaStreamInfo::metadata() const
{
    return m_metadata;
}

double MediaStreamInfo::bit_rate() const
{
    return m_bit_rate;
}
