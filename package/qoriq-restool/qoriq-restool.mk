################################################################################
#
# qoriq-restool
#
################################################################################

QORIQ_RESTOOL_VERSION = lf-6.12.3-1.0.0-3-g8f73f26
QORIQ_RESTOOL_SITE = $(call github,nxp-qoriq,restool,$(QORIQ_RESTOOL_VERSION))
QORIQ_RESTOOL_LICENSE = BSD-3-Clause or GPL-2.0-or-later
QORIQ_RESTOOL_LICENSE_FILES = COPYING

QORIQ_RESTOOL_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)"

define QORIQ_RESTOOL_BUILD_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(MAKE) $(QORIQ_RESTOOL_MAKE_OPTS)
endef

define QORIQ_RESTOOL_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) MANPAGE="" $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) \
		prefix=/usr install
endef

$(eval $(generic-package))
