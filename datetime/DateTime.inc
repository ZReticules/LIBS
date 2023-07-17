StartPoint equ 1980

extrn DateTime_GetHourMinuteSecond  :far
extrn DateTime_GetSecond            :far
extrn DateTime_GetMinute            :far
extrn DateTime_GetHour              :far
extrn DateTime_GetYearMonthDay      :far
extrn DateTime_GetYear              :far
extrn DateTime_GetMonth             :far
extrn DateTime_GetDay               :far
extrn DateTime_InToUnix             :far
extrn DateTime_StrToUnix            :far
extrn DateTime_UnixToStr            :far
extrn DateTime_GetNow               :far
extrn DateTime_AddMonth             :far
extrn DateTime_AddYear              :far
extrn TimeSpan_GetSecond            :far
extrn TimeSpan_GetMinute            :far
extrn TimeSpan_GetHour              :far
extrn TimeSpan_GetDay               :far
extrn TimeSpan_InToUnix             :far
extrn TimeSpan_UnixToStr            :far
extrn TimeSpan_StrToUnix            :far
extrn DateTime_AddDay               :far
extrn DateTime_AddHour              :far
extrn DateTime_AddMinute            :far
extrn DateTime_SetDate              :far
extrn DateTime_SetTime              :far

DateTime struc global method{
        New:dword       = DateTime_InToUnix
        FromString:dword= DateTime_StrToUnix
        ToString:dword  = DateTime_UnixToStr
        GetNow:dword    = DateTime_GetNow
        GetSecond:dword = DateTime_GetSecond
        GetMinute:dword = DateTime_GetMinute
        GetHour:dword   = DateTime_GetHour
        GetDay:dword    = DateTime_GetDay
        GetMonth:dword  = DateTime_GetMonth
        GetYear:dword   = DateTime_GetYear
        AddYear:dword   = DateTime_AddYear
        AddMonth:dword  = DateTime_AddMonth
        AddDay:dword    = DateTime_AddDay
        AddHour:dword   = DateTime_AddHour
        AddMinute:dword = DateTime_AddMinute
        SetDate:dword   = DateTime_SetDate
        SetTime:dword   = DateTime_SetTime
    }
    dd ?
ends

TimeSpan struc global method{
        New:dword       = TimeSpan_InToUnix
        FromString:dword= TimeSpan_StrToUnix
        ToString:dword  = TimeSpan_UnixToStr
        GetSecond:dword = TimeSpan_GetSecond
        GetMinute:dword = TimeSpan_GetMinute
        GetHour:dword   = TimeSpan_GetHour
        GetDay:dword    = TimeSpan_GetDay
        AddDay:dword    = DateTime_AddDay
        AddHour:dword   = DateTime_AddHour
        AddMinute:dword = DateTime_AddMinute
    }
    dd ?
ends

DateTime_New macro Name:REQ, Year:=<StartPoint>, Month:=<1>, Day:=<1>, Hour:=<0>, Minute:=<0>, Second:=<0>, Count:=<1>
local @UnixTime, @MonthInc, Leap, @Month, @Months
local m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11
m1  = 31
m2  = 28
m3  = 31
m4  = 30
m5  = 31
m6  = 30
m7  = 31
m8  = 31 
m9  = 30
m10 = 31
m11 = 30
    ERRIF (Month GT 12) OR (Month LT 1) 'Month not found'
    ERRIF (Year GT StartPoint+136) OR (Year LT StartPoint) 'Year out of range'
    @Unixtime=0  
    @MonthInc=0
    Leap = Year-Year/4*4
    IF Leap EQ 0
        m2=m2+1
        Leap = 1
    ELSE
        Leap = 0
    ENDIF
    @Unixtime=((Year-StartPoint)*365+(Year-StartPoint-Leap)/4)
    IRP @Month, <m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11>
        IF @MonthInc EQ Month-1
            exitm
        ENDIF
        @MonthInc=@MonthInc+1
        @UnixTime=@UnixTime+@Month
    endm
    IF Year EQ StartPoint
        Leap = 1
    ELSE
        Leap = 0
    ENDIF
    @Unixtime=(((@UnixTime+Day-Leap)*24+Hour)*60+Minute)*60+Second
    Name DateTime Count dup (<@UnixTime>)
endm

TimeSpan_New macro Name:REQ, Day:=<0>, Hour:=<0>, Minute:=<0>, Second:=<0>, Count:=<1>
    Name TimeSpan Count dup (<((Day*24+Hour)*60+Minute)*60+Second>)
endm
