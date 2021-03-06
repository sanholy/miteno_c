#file searching path
CROSS_COMPILE=arm-unknown-linux-gnu-
CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
AR=$(CROSS_COMPILE)ar
RM=rm
CP=cp
MAKENLD=makenld
STRIP=arm-unknown-linux-gnu-strip

# 应用程序目录定义
BINDIR    = bin
SRCDIR    = src
INCDIR    = inc
OBJDIR    =	obj_err
LIBDIR    =	lib
LIBAPIDIR =	libapi
OTHERFILEDIR = otherfile
LEDDIR    = led
SIGNDIR   =	sign_app

#API目录定义
APIDIR= 	biosapi


#转换时间
POSDATE = $(subst :, , $(shell date))
#取分
POSMINUTE = $(word 5, $(POSDATE))
#取秒
POSSECOND = $(word 6, $(POSDATE))
#取年
POSYEAR = $(word 7, $(POSDATE))
#取日
ifeq ($(word 3, $(POSDATE)),1)
POSDAY = 01
else
ifeq ($(word 3, $(POSDATE)),2)
POSDAY = 02
else
ifeq ($(word 3, $(POSDATE)),3)
POSDAY = 03
else
ifeq ($(word 3, $(POSDATE)),4)
POSDAY = 04
else
ifeq ($(word 3, $(POSDATE)),5)
POSDAY = 05
else
ifeq ($(word 3, $(POSDATE)),6)
POSDAY = 06
else
ifeq ($(word 3, $(POSDATE)),7)
POSDAY = 07
else
ifeq ($(word 3, $(POSDATE)),8)
POSDAY = 08
else
ifeq ($(word 3, $(POSDATE)),9)
POSDAY = 09
else
POSDAY = $(word 3, $(POSDATE))
endif
endif
endif
endif
endif
endif
endif
endif
endif
#取月
ifeq ($(word 2, $(POSDATE)),Jan)
POSMONTH = 01
else
ifeq ($(word 2, $(POSDATE)),Feb)
POSMONTH = 02
else
ifeq ($(word 2, $(POSDATE)),Mar)
POSMONTH = 03
else
ifeq ($(word 2, $(POSDATE)),Apr)
POSMONTH = 04
else
ifeq ($(word 2, $(POSDATE)),May)
POSMONTH = 05
else
ifeq ($(word 2, $(POSDATE)),Jun)
POSMONTH = 06
else
ifeq ($(word 2, $(POSDATE)),Jul)
POSMONTH = 07
else
ifeq ($(word 2, $(POSDATE)),Aug)
POSMONTH = 08
else
ifeq ($(word 2, $(POSDATE)),Sep)
POSMONTH = 09
else
ifeq ($(word 2, $(POSDATE)),Nov)
POSMONTH = 11
else
ifeq ($(word 2, $(POSDATE)),Dec)
POSMONTH = 12
else
POSMONTH = 10
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif


DATE := $(POSYEAR)$(POSMONTH)$(POSDAY)

#中国银联规范版本号
ZGYLVER = 31
#版本序号(每次定版，版本都要递增!!!!)
VERNO = 11
#主版本号
APPVER := $(ZGYLVER)$(POSMINUTE)$(POSSECOND)
APPVERSION :=$(join "\",$(APPVER)\"")
INTERVER := $(join "\",$(DATE)$(VERNO)\"") 

#CFLAGS += -D EMV_IC
#CFLAGS += -D SUPPORT_ELECSIGN
#CFLAGS += -Wall -Werror -DNDEBUG $(CROSS_CFLAGS) -O2 $(INCPATH)
CFLAGS += -Wall -DNDEBUG $(CROSS_CFLAGS) -O2 $(INCPATH)
CFLAGS += -D APP_VERSION=$(APPVERSION)
CFLAGS += -D APP_VERSION_DISP=$(APPVERSION)
CFLAGS += -D INTER_VER=$(INTERVER)



#生成NLD名字,注意修改应用英文名
ifeq ($(DEBUGFLAG),DEBUG)
#调式版本
ISDEBUG = 1,0,0
ifeq ($(TMSFUNC),USETMS)
CFLAGS += -D USE_TMS
NLDNAME =main_Tms_DEBUG.NLD
else
NLDNAME = main_DEBUG.NLD
endif
else
#正式版本
ISDEBUG = 0,0,0
ifeq ($(TMSFUNC),USETMS)
CFLAGS += -D USE_TMS
NLDNAME = AAZGYL00$(APPVER)$(POSMONTH)$(VERNO).NLD
else
NLDNAME = main.NLD
endif
endif


#文件搜索路径
VPATH = src $(OBJDIR)

#头文件搜索路径
INCLPATH = -I$(INCDIR) -I$(LIBAPIDIR) -I$(APIDIR)

# 程序链接参数
LDFLAGS += -L$(APIDIR) -lndk
LDFLAGS += -L$(LIBDIR) -lui -ltool -lcomm -lsecurity -lprint -lcard -lluapos
LDFLAGS += -L$(LIBDIR) -lemv -ldl
#ifeq ($(TMSFUNC),USETMS)
LDFLAGS += -L$(LIBDIR) -lmc
#endif

# 生成的程序名
NAME = main

#打包文件
PICPNG  = *.png
PICBMP  = *.bmp
PICJPG  = *.jpg
FILELUA = *.lua
FILEPRT = ALLPAYPNT
SIGNAPP = sign_main

# 程序中用到的模块
SRCS=		$(wildcard $(SRCDIR)/*.c)
SRSS=		$(notdir $(SRCS))
OBJS=		$(subst .c,.o,$(SRSS))

OBJSD=		$(subst $(SRCDIR)/,$(OBJDIR)/,$(SRCS))
OBJSY=		$(subst .c,.o,$(OBJSD))


#包含依赖文件
all: NLD

$(NAME):config $(OBJS)
	$(CC) $(CFLAGS) -o $(BINDIR)/$(NAME) $(OBJSY) $(LDFLAGS)
	$(STRIP) $(BINDIR)/$(NAME)
#	iniupdate strVerBuf=$(APPVER) $(BINDIR)/headerinfo.ini
#	iniupdate strBuildTime=$(DATE) $(BINDIR)/headerinfo.ini
#	iniupdate sReverse=$(ISDEBUG) $(BINDIR)/headerinfo.ini
#%.o: %.c
#	$(CC) -c $(CFLAGS) $(INCLPATH) $< -o $(OBJDIR)/$(subst .c,.o,$@) 
#	$(CC) -c $(CFLAGS) $(INCLPATH) $< -o $(OBJDIR)/$@ >& $(OBJDIR)/$(notdir $(basename $<)).err

#自动生成依赖文件
config: $(subst .o,.deps, $(OBJS))

%.o: %.c 
	$(CC) -c  $(CFLAGS) $(INCLPATH) $< -o  $(OBJDIR)/$(subst .c,.o,$@) >$(OBJDIR)/$(subst .o,.err,$@) 2>&1
%.deps: %.c
	$(CC) -M $(INCLPATH) $< > $(OBJDIR)/$@ 

	
.PHONY:clean
clean:
	-$(RM) $(BINDIR)/$(NAME)
	-$(RM) $(OBJDIR)/*.o
	-$(RM) $(OBJDIR)/*.deps
	
NLD:$(NAME)
	$(CP) $(BINDIR)/$(OTHERFILEDIR)/*[^CVS,^cvs] $(BINDIR)/
	$(CP) $(BINDIR)/$(LEDDIR)/*[^CVS,^cvs] $(BINDIR)/
	$(CP) $(BINDIR)/$(SIGNDIR)/*[^CVS,^cvs] $(BINDIR)/
	$(MAKENLD) -h HeaderInfo.ini -f main $(PICPNG) $(PICBMP) $(PICJPG) $(FILELUA) $(FILEPRT) $(SIGNAPP) pri_* -o $(NLDNAME) -C $(BINDIR)/ 
	$(RM) $(BINDIR)/$(PICPNG) $(BINDIR)/$(PICBMP) $(BINDIR)/$(PICJPG)
	$(RM) $(BINDIR)/$(FILELUA) $(BINDIR)/$(FILEPRT) $(BINDIR)/$(SIGNAPP)
	
	
