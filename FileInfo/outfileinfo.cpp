#include "outfileinfo.h"

OutVideoInfo::OutVideoInfo()
{

}

QString OutVideoInfo::videoCodes() const
{
    return m_videoCodes;
}

void OutVideoInfo::setVideoCodes(const QString &newVideoCodes)
{
    if (m_videoCodes == newVideoCodes)
        return;
    m_videoCodes = newVideoCodes;
    emit videoCodesChanged();
}

QString OutVideoInfo::resolution() const
{
    return m_resolution;
}

void OutVideoInfo::setResolution(const QString &newResolution)
{
    if (m_resolution == newResolution)
        return;
    m_resolution = newResolution;
    emit resolutionChanged();
}

float OutVideoInfo::frameRate() const
{
    return m_frameRate;
}

void OutVideoInfo::setFrameRate(float newFrameRate)
{
    if (qFuzzyCompare(m_frameRate, newFrameRate))
        return;
    m_frameRate = newFrameRate;
    emit frameRateChanged();
}

float OutVideoInfo::bitRate() const
{
    return m_bitRate;
}

void OutVideoInfo::setBitRate(float newBitRate)
{
    if (qFuzzyCompare(m_bitRate, newBitRate))
        return;
    m_bitRate = newBitRate;
    emit bitRateChanged();
}

OutAudioInfo::OutAudioInfo()
{

}

QString OutAudioInfo::audioCodes() const
{
    return m_audioCodes;
}

void OutAudioInfo::setAudioCodes(const QString &newAudioCodes)
{
    if (m_audioCodes == newAudioCodes)
        return;
    m_audioCodes = newAudioCodes;
    emit audioCodesChanged();
}

int OutAudioInfo::channels() const
{
    return m_channels;
}

void OutAudioInfo::setChannels(const int &newChannels)
{
    if (m_channels == newChannels)
        return;
    m_channels = newChannels;
    emit channelsChanged();
}

int OutAudioInfo::audioSamplefmt() const
{
    return m_audioSamplefmt;
}

void OutAudioInfo::setAudioSamplefmt(const int &newAudioSamplefmt)
{
    if (m_audioSamplefmt == newAudioSamplefmt)
        return;
    m_audioSamplefmt = newAudioSamplefmt;
    emit audioSamplefmtChanged();
}

float OutAudioInfo::bitRate() const
{
    return m_bitRate;
}

void OutAudioInfo::setBitRate(float newBitRate)
{
    if (qFuzzyCompare(m_bitRate, newBitRate))
        return;
    m_bitRate = newBitRate;
    emit bitRateChanged();
}

QString OutFileInfo::format() const
{
    return m_format;
}

OutFileInfo::OutFileInfo()
{
    m_audioInfo=new OutAudioInfo();
    m_videoInfo=new OutVideoInfo();
}
void OutFileInfo::setFormat(const QString &newFormat)
{
    if (m_format == newFormat)
        return;
    m_format = newFormat;
    emit formatChanged();
}

OutAudioInfo *OutFileInfo::audioInfo() const
{
    return m_audioInfo;
}

OutVideoInfo *OutFileInfo::videoInfo() const
{
    return m_videoInfo;
}

bool OutVideoInfo::discard() const
{
    return m_discard;
}

void OutVideoInfo::setDiscard(bool newDiscard)
{
    if (m_discard == newDiscard)
        return;
    m_discard = newDiscard;
    emit discardChanged();
}

bool OutAudioInfo::discard() const
{
    return m_discard;
}

void OutAudioInfo::setDiscard(bool newDiscard)
{
    if (m_discard == newDiscard)
        return;
    m_discard = newDiscard;
    emit discardChanged();
}
