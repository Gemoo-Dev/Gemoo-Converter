#include "videoinfo.h"

VideoInfo::VideoInfo(const AVStream* stream,QObject *parent)
    : MediaStreamInfo{stream,parent}
{
    m_width=stream->codec->width;
    m_height=stream->codec->height;  
    m_frame_rate = av_q2d(stream->avg_frame_rate);  
    m_pix_fmt = av_get_pix_fmt_name(stream->codec->pix_fmt);   
    m_color_primaries =  av_color_primaries_name(stream->codec->color_primaries);    
}

int VideoInfo::width() const
{
    return m_width;
}

int VideoInfo::height() const
{
    return m_height;
}

QString VideoInfo::formatProfile() const
{
    return m_formatProfile;
}

double VideoInfo::frame_rate() const
{
    return m_frame_rate;
}

QString VideoInfo::pix_fmt() const
{
    return m_pix_fmt;
}
QString VideoInfo::color_primaries() const
{
    return m_color_primaries;
}

