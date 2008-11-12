#
# Copyright (C) 2007-2008 B.A.T.M.A.N. contributors:
# Marek Lindner, Simon Wunderlich
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public
# License as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA
#



PWD:=$(shell pwd)
ifeq ($(wildcard $(KERNELPATH)),)
KERNELPATH = /lib/modules/$(shell uname -r)/build
# sanity check: does KERNELPATH exist?
ifeq ($(shell cd $(KERNELPATH) && pwd),)
$(error $(KERNELPATH) is missing, please set KERNELPATH)
endif
export KERNELPATH
endif

REVISION=	$(shell if [ -d .svn ]; then \
						if which svn > /dev/null; then \
							svn info | grep "Rev:" | sed -e '1p' -n | awk '{print $$4}'; \
						else \
							echo "[unknown]"; \
						fi ; \
					else \
						if [ -d ~/.svk ]; then \
							if which svk > /dev/null; then \
								echo $$(svk info | grep "Mirrored From" | awk '{print $$5}'); \
							else \
								echo "[unknown]"; \
							fi; \
						fi; \
					fi)

NUM_CPUS = $(shell NUM_CPUS=`cat /proc/cpuinfo | grep -v 'model name' | grep processor | tail -1 | awk -F' ' '{print $$3}'`;echo `expr $$NUM_CPUS + 1`)

include $(PWD)/Makefile.kbuild

all:
	make -C $(KERNELPATH) REVISION=$(REVISION) M=$(PWD) PWD=$(PWD) -j $(NUM_CPUS) modules

clean:
	make -C $(KERNELPATH) M=$(PWD) PWD=$(PWD) clean