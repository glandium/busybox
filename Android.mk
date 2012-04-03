include $(CLEAR_VARS)

BUSYBOX_TOOLS := \
	ar \
	arp \
	ash \
	awk \
	base64 \
	basename \
	beep \
	blkid \
	blockdev \
	bunzip2 \
	bzcat \
	bzip2 \
	cal \
	catv \
	chat \
	chattr \
	chgrp \
	chpst \
	chroot \
	chrt \
	chvt \
	cksum \
	clear \
	comm \
	cp \
	cpio \
	cttyhack \
	cut \
	dc \
	deallocvt \
	depmod \
	devmem \
	diff \
	dirname \
	dnsd \
	dos2unix \
	dpkg \
	dpkg-deb \
	du \
	dumpkmap \
	echo \
	ed \
	egrep \
	envdir \
	envuidgid \
	expand \
	fakeidentd \
	false \
	fbset \
	fbsplash \
	fdflush \
	fdformat \
	fdisk \
	fgconsole \
	fgrep \
	find \
	findfs \
	flash_lock \
	flash_unlock \
	flashcp \
	flock \
	fold \
	freeramdisk \
	ftpd \
	ftpget \
	ftpput \
	fuser \
	getopt \
	grep \
	gunzip \
	gzip \
	halt \
	hdparm \
	head \
	hexdump \
	httpd \
	ifdown \
	ifup \
	init \
	inotifyd \
	install \
	iostat \
	ip \
	ipaddr \
	ipcalc \
	iplink \
	iproute \
	iprule \
	iptunnel \
	klogd \
	linuxrc \
	loadkmap \
	losetup \
	lpd \
	lpq \
	lpr \
	lsattr \
	lspci \
	lsusb \
	lzcat \
	lzma \
	lzop \
	lzopcat \
	makedevs \
	makemime \
	man \
	md5sum \
	mesg \
	mkfifo \
	mknod \
	mkswap \
	mktemp \
	modinfo \
	modprobe \
	more \
	mpstat \
	nbd-client \
	nc \
	nice \
	nmeter \
	nohup \
	od \
	openvt \
	patch \
	pidof \
	ping \
	pipe_progress \
	pmap \
	popmaildir \
	poweroff \
	powertop \
	printf \
	pscan \
	pstree \
	pwd \
	pwdx \
	raidautorun \
	rdev \
	readlink \
	readprofile \
	realpath \
	reformime \
	reset \
	resize \
	rev \
	rpm \
	rpm2cpio \
	rtcwake \
	run-parts \
	runsv \
	runsvdir \
	rx \
	script \
	scriptreplay \
	sed \
	sendmail \
	seq \
	setkeycodes \
	setlogcons \
	setserial \
	setsid \
	setuidgid \
	sha1sum \
	sha256sum \
	sha512sum \
	showkey \
	smemcap \
	softlimit \
	sort \
	split \
	start-stop-daemon \
	strings \
	stty \
	sum \
	sv \
	svlogd \
	sysctl \
	tac \
	tail \
	tar \
	tcpsvd \
	tee \
	telnet \
	telnetd \
	test \
	time \
	timeout \
	tr \
	traceroute \
	true \
	ttysize \
	tunctl \
	tune2fs \
	udhcpc \
	uname \
	uncompress \
	unexpand \
	uniq \
	unix2dos \
	unlzma \
	unlzop \
	unxz \
	unzip \
	uudecode \
	uuencode \
	vi \
	volname \
	watch \
	wc \
	wget \
	which \
	whoami \
	whois \
	xargs \
	xz \
	xzcat \
	yes \
	zcat

BB_TC_DIR := $(realpath $(shell dirname $(TARGET_TOOLS_PREFIX)))
BB_TC_PREFIX := $(shell basename $(TARGET_TOOLS_PREFIX))
BB_LDFLAGS := -Xlinker -z -Xlinker muldefs -nostdlib -Bdynamic -Xlinker -T../../$(BUILD_SYSTEM)/armelf.x -Xlinker -dynamic-linker -Xlinker /system/bin/linker -Xlinker -z -Xlinker nocopyreloc -Xlinker --no-undefined ../../$(TARGET_CRTBEGIN_DYNAMIC_O) ../../$(TARGET_CRTEND_O) -L../../$(TARGET_OUT_STATIC_LIBRARIES)
# FIXME remove -fno-strict-aliasing once all aliasing violations are fixed
BB_COMPILER_FLAGS := $(subst -I ,-I../../,$(subst -include ,-include ../../,$(TARGET_GLOBAL_CFLAGS))) -I../../bionic/libc/include -I../../bionic/libc/kernel/common -I../../bionic/libc/arch-arm/include -I../../bionic/libc/kernel/arch-arm -I../../bionic/libm/include -fno-stack-protector -Wno-error=format-security -fno-strict-aliasing
BB_LDLIBS := dl m c gcc
ifneq ($(strip $(SHOW_COMMANDS)),)
BB_VERBOSE="V=1"
endif

.PHONY: busybox

droid: busybox

systemtarball: busybox

busybox: $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O) $(TARGET_OUT_STATIC_LIBRARIES)/libm.so $(TARGET_OUT_STATIC_LIBRARIES)/libc.so $(TARGET_OUT_STATIC_LIBRARIES)/libdl.so
	cd external/busybox && \
	sed -e "s|^CONFIG_CROSS_COMPILER_PREFIX=.*|CONFIG_CROSS_COMPILER_PREFIX=\"$(BB_TC_PREFIX)\"|;s|^CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS=\"$(BB_COMPILER_FLAGS)\"|" configs/android_defconfig >.config && \
	export PATH=$(BB_TC_DIR):$(PATH) && \
	$(MAKE) oldconfig && \
	$(MAKE) $(BB_VERBOSE) EXTRA_LDFLAGS="$(BB_LDFLAGS)" LDLIBS="$(BB_LDLIBS)" && \
	mkdir -p ../../$(PRODUCT_OUT)/system/bin && \
	cp busybox ../../$(PRODUCT_OUT)/system/bin/

symlinks: busybox
	for link in $(BUSYBOX_TOOLS); do\
		ln -sf busybox $(PRODUCT_OUT)/system/bin/$$link; done
