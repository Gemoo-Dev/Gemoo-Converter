#include "subtitleinfo.h"

SubtitleInfo::SubtitleInfo(const AVStream* stream,QObject *parent)
    : MediaStreamInfo{stream,parent}
{}
