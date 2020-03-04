#!/usr/bin/env bash
# Copyright (C) 2018 Abubakar Yagob (blacksuan19)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# SPDX-License-Identifier: GPL-3.0-or-later

# Color
green='\033[0;32m'
echo -e "$green"

# Main Environment
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/ak2-KryPtoN
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs
CONFIG=vince-krypton_defconfig
CORES=$(grep -c ^processor /proc/cpuinfo)
THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$PWD/stock/bin/aarch64-linux-android-"

# Modules environtment
OUTDIR="$PWD/out/"
SRCDIR="$PWD/"
MODULEDIR="$PWD/ak2-KryPtoN/modules/system/lib/modules/"
PRONTO=${MODULEDIR}pronto/pronto_wlan.ko
STRIP="$PWD/stock/bin/$(echo "$(find "$PWD/stock/bin" -type f -name "aarch64-*-gcc")" | awk -F '/' '{print $NF}' |\
			sed -e 's/gcc/strip/')"

#Telergam Variable
KERNEL_NAME="KryPtoN"
CODE="PWR"
LINUX="UBUNTU 19.04"
DEVICE="Xiaomi Redmi 5 Plus(Vince) MIUI"
VERSION="v1.0"
KVERSION="3.18.137"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
BOT_API_KEY=$(openssl enc -base64 -d <<< NzE1ODAxNzAwOkFBRW5sWGdsMHA4VjVmOHhIZWZIQzJTTHE4a2lvNlZjUy1jCg==)
CHAT_ID="-1001348632957"
ZIP_NAME="${KERNEL_NAME}-${CODE}-$(date "+%Y%m%d-%H%M").zip"
COMPILE="$PWD/stock/bin/aarch64-linux-android-"
COMP_VERSION=$(${COMPILE}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

#Telegram Function

                function kirim() {
                         curl -F chat_id="$CHAT_ID" -F document=@"$ZIP_DIR/$ZIP_NAME" https://api.telegram.org/bot$BOT_API_KEY/sendDocument
                }

                function kirim_info() {
                        curl -s "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
				-d "parse_mode=markdown" \
				-d text="${1}" \
				-d chat_id="$CHAT_ID" \
				-d "disable_web_page_preview=true"
                }

                function error() {
                        kirim_info "$(echo -e "Build Failed, Check log for more info")"
                         exit 1
                }

		function kirimsetiker() {
			curl -s -F chat_id="$CHAT_ID" -F sticker="CAADBQADBgADZMYlHVmIXcRlbUt_Ag" https://api.telegram.org/bot$BOT_API_KEY/sendSticker
		}

		function selesai() {
			kirim_info "$(echo -e "Build Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
		}

                

# Export
export ARCH=arm64
export SUBARCH=arm64
export PATH=/usr/lib/ccache:$PATH
export CROSS_COMPILE

# Is this logo
echo -e "---------------------------------------------------------------------";
echo -e "---------------------------------------------------------------------\n";
echo -e " _  ________   ______ _____ ___  _   _   _  _______ ____  _   _ _____ _    "; 
echo -e "| |/ /  _ \ \ / /  _ \_   _/ _ \| \ | | | |/ / ____|  _ \| \ | | ____| |    ";
echo -e "| ' /| |_) \ V /| |_) || || | | |  \| | | ' /|  _| | |_) |  \| |  _| | |    ";
echo -e "| . \|  _ < | | |  __/ | || |_| | |\  | | . \| |___|  _ <| |\  | |___| |___ ";
echo -e "|_|\_\_| \_\|_| |_|    |_| \___/|_| \_| |_|\_\_____|_| \_\_| \_|_____|_____|\n";
echo -e "---------------------------------------------------------------------";
echo -e "---------------------------------------------------------------------";

# Main script
while true; do
	echo -e "\n[1] Build Vince MIUI Kernel"
	echo -e "[2] Regenerate defconfig"
	echo -e "[3] Source cleanup"
	echo -e "[4] Create flashable zip"
	echo -e "[5] Build CI"
	echo -e "[6] Quit"
	echo -ne "\n(i) Please enter a choice[1-6]: "
	
	read choice
	
	if [ "$choice" == "1" ]; then
		echo -e "\n(i) Cloning AnyKernel2 if folder not exist..."
		git clone https://github.com/rama982/AnyKernel2 -b vince-miui
	
		echo -e "\n(i) Cloning toolcahins if folder not exist..."
		git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 --depth=1 stock 
	
		echo -e ""
		make  O=out $CONFIG $THREAD &>/dev/null
		make  O=out $THREAD & pid=$!   
	
		BUILD_START=$(date +"%s")
		DATE=`date`

		echo -e "\n#######################################################################"

		echo -e "(i) Build started at $DATE using $CORES thread"

		spin[0]="-"
		spin[1]="\\"
		spin[2]="|"
		spin[3]="/"
		echo -ne "\n[Please wait...] ${spin[0]}"
		while kill -0 $pid &>/dev/null
		do
			for i in "${spin[@]}"
			do
				echo -ne "\b$i"
				sleep 0.1
			done
		done
	
		if ! [ -a $KERN_IMG ]; then
			echo -e "\n(!) Kernel compilation failed, See buildlog to fix errors"
			echo -e "#######################################################################"
			exit 1
		fi
	
		BUILD_END=$(date +"%s")
		DIFF=$(($BUILD_END - $BUILD_START))

		echo -e "\n(i) Image-dtb compiled successfully."

		echo -e "#######################################################################"

		echo -e "(i) Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "2" ]; then
		echo -e "\n#######################################################################"

		make O=out  $CONFIG savedefconfig &>/dev/null
		cp out/defconfig arch/arm64/configs/$CONFIG &>/dev/null

		echo -e "(i) Defconfig generated."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "3" ]; then
		echo -e "\n#######################################################################"

		make O=out clean &>/dev/null
		make mrproper &>/dev/null
		rm -rf out/*

		echo -e "(i) Kernel source cleaned up."

		echo -e "#######################################################################"
	fi
	
	if [ "$choice" == "4" ]; then
		echo -e "\n#######################################################################"

		echo -e "\n(i) Strip and move modules to AnyKernel2..."

		# thanks to @adekmaulana

		cd $ZIP_DIR
		make clean &>/dev/null
		cd ..
	
		for MOD in $(find "${OUTDIR}" -name '*.ko') ; do
			"${STRIP}" --strip-unneeded --strip-debug "${MOD}" &> /dev/null
			"${SRCDIR}"/scripts/sign-file sha512 \
					"${OUTDIR}/signing_key.priv" \
					"${OUTDIR}/signing_key.x509" \
					"${MOD}"
			find "${OUTDIR}" -name '*.ko' -exec cp {} "${MODULEDIR}" \;
			case ${MOD} in
				*/wlan.ko)
					cp -ar "${MOD}" "${PRONTO}"
			esac
		done
		echo -e "\n(i) Done moving modules"

		cd $ZIP_DIR
		cp $KERN_IMG $ZIP_DIR/zImage
		make normal &>/dev/null
		cd ..

		echo -e "(i) Flashable zip generated under $ZIP_DIR."

		echo -e "#######################################################################"
	fi

        if [ "$choice" == "5" ]; then

		kirim_info " *KryPtoN* Kernel New Build!
*Started on:* ${LINUX}
*Device:* ${DEVICE}
*Kernel Version:* ${KVERSION}
*Version:* ${VERSION}
*At branch:* ${BRANCH}
*Commit:* $(git log --pretty=format:'%h : %s' -1)
*Compiler:* ${COMP_VERSION}
*Strated on:* $(date) "
                
                echo -e " "
		echo -e "\n(i) Cloning ak2-KryPtoN if folder not exist..."
		git clone https://github.com/Kry9toN/ak2-KryPtoN -b miui
	
		echo -e "\n(i) Cloning toolcahins if folder not exist..."
		git clone https://github.com/najahiiii/aarch64-linux-gnu.git -b gcc9-20190401 --depth=1 stock
	
		echo -e ""
		make  O=out $CONFIG $THREAD &>/dev/null
		make  O=out $THREAD & pid=$!   
	
		BUILD_START=$(date +"%s")
		DATE=`date`

		echo -e "\n#######################################################################"

		echo -e "(i) Build started at $DATE using $CORES thread"

		spin[0]="-"
		spin[1]="\\"
		spin[2]="|"
		spin[3]="/"
		echo -ne "\n[Please wait...] ${spin[0]}"
		while kill -0 $pid &>/dev/null
		do
			for i in "${spin[@]}"
			do
				echo -ne "\b$i"
				sleep 0.1
			done
		done
	
		if ! [ -a $KERN_IMG ]; then
			echo -e "\n(!) Kernel compilation failed, See buildlog to fix errors"
			echo -e "#######################################################################"
			error
			exit 1
		fi
	
		BUILD_END=$(date +"%s")
		DIFF=$(($BUILD_END - $BUILD_START))

		echo -e "\n(i) Image-dtb compiled successfully."
		echo -e "#######################################################################"
                echo -e " "

		echo -e "\n(i) Strip and move modules to ak2-Krypton..."

		# thanks to @adekmaulana

		cd $ZIP_DIR
		make clean &>/dev/null
		cd ..
	
		for MOD in $(find "${OUTDIR}" -name '*.ko') ; do
			"${STRIP}" --strip-unneeded --strip-debug "${MOD}" &> /dev/null
			"${SRCDIR}"/scripts/sign-file sha512 \
					"${OUTDIR}/signing_key.priv" \
					"${OUTDIR}/signing_key.x509" \
					"${MOD}"
			find "${OUTDIR}" -name '*.ko' -exec cp {} "${MODULEDIR}" \;
			case ${MOD} in
				*/wlan.ko)
					cp -ar "${MOD}" "${PRONTO}"
			esac
		done
		echo -e "\n(i) Done moving modules"

		cd $ZIP_DIR
		cp $KERN_IMG $ZIP_DIR/zImage
		make ZIP="${ZIP_NAME}" normal &>/dev/null
		cd ..

		echo -e "(i) Flashable zip generated under $ZIP_DIR."

                echo -e " "              


                echo -e "Clean Kernel source"
		echo -e " "

		make O=out clean &>/dev/null
		make mrproper &>/dev/null
		rm -rf out/*

		echo -e "Kernel source cleaned up"
                echo -e " "
                echo -e "#######################################################################"

		echo -e "(i) Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

		echo -e "#######################################################################"
		echo -e " "
                echo -e "Send to Telegram" 

		kirim
		selesai
		kirimsetiker
	fi	

	if [ "$choice" == "6" ]; then
		exit 
	fi

done
echo -e "$nc"
