#include "audioinfo.h"

AudioInfo::AudioInfo(const AVStream* stream,QObject *parent)
    : MediaStreamInfo{stream,parent}
{
    m_channels=  stream->codecpar->channels;
    m_sample_fmt=av_get_sample_fmt_name( stream->codec->sample_fmt);
    m_sample_rate=stream->codecpar->sample_rate;
}

int AudioInfo::channels() const
{
    return m_channels;
}

QString AudioInfo::sample_fmt() const
{
    return m_sample_fmt;
}

int AudioInfo::sample_rate() const
{
    return m_sample_rate;
}
