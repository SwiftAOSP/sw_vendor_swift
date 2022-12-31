#
# Copyright (C) 2020 The ConquerOS Project
# Copyright (C) 2021 a xdroid Prjkt
# Copyright (C) 2022 SwiftAOSP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#



# ART
# Optimize everything for preopt
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := everything

ifeq ($(TARGET_SUPPORTS_64_BIT_APPS), true)
# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/swift/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/swift/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/swift/prebuilt/common/bin/50-swift.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-swift.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/swift/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/swift/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/swift/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
endif

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/swift/config/permissions/backup.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/backup.xml

# Copy all swift-specific init rc files
$(foreach f,$(wildcard vendor/swift/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/swift/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.nfc.beam.xml

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0719.kl

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/swift/overlay
DEVICE_PACKAGE_OVERLAYS += vendor/swift/overlay/common

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/swift/prebuilt/common/etc/sensitive_pn.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sensitive_pn.xml

# Enable whole-program R8 Java optimizations for SystemUI and system_server
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

# Use default filter for problematic apps.
PRODUCT_DEXPREOPT_QUICKEN_APPS += \
    Dialer

# Do not preoptimize prebuilts when building GApps
DONT_DEXPREOPT_PREBUILTS := true

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/swift/overlay/dictionaries

# Disable EAP Proxy because it depends on proprietary headers
# and breaks WPA Supplicant compilation.
DISABLE_EAP_PROXY := true

ifneq ($(HOST_OS),linux)
ifneq ($(sdclang_already_warned),true)
$(warning **********************************************)
$(warning * SDCLANG is not supported on non-linux hosts.)
$(warning **********************************************)
sdclang_already_warned := true
endif
else

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED := false
ifneq ($(TARGET_DISABLE_ALTERNATIVE_FACE_UNLOCK), true)
PRODUCT_PACKAGES += \
    FaceUnlockService
TARGET_FACE_UNLOCK_SUPPORTED := true
endif
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face.moto_unlock_service=$(TARGET_FACE_UNLOCK_SUPPORTED)

# init.rc
$(foreach f,$(wildcard vendor/swift/prebuilt/etc/init/*.rc),\
    $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# include definitions for SDCLANG
include vendor/swift/sdclang/sdclang.mk
endif

# Include Sweetea
include vendor/sweetea/configs/common.mk

# Include Swift packages
include vendor/swift/config/packages.mk

# Include Common props
include vendor/swift/config/props.mk

# Include Version
include vendor/swift/config/version.mk
