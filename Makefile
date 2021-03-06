# Low-tech Makefile to build and install dylan-tool.

# Building an executable for a library named "dylan" causes a conflict with the
# base dylan library. I want this tool to be named "dylan" on the command line,
# so it's necessary to use a makefile to build and then rename the executable
# during the installation process.

# Because there's currently no way to make a static executable this gets
# installed with the following directory structure:
#
#   ${DYLAN}/install/dylan-tool/bin/dylan-tool          # dylan-tool executable
#   ${DYLAN}/install/dylan-tool/lib/*                   # dylan-tool used libraries
#   ${DYLAN}/bin/dylan                                  # symlink
#      -> ../install/dylan-tool/bin/dylan-tool          #   to here
#
# So just make sure ${DYLAN}/bin (or ${HOME}/dylan/bin, the default) is on your path.

DYLAN		?= $${HOME}/dylan
install_dir     = $(DYLAN)/install/dylan-tool
install_bin     = $(install_dir)/bin
install_lib     = $(install_dir)/lib
link_target     = $(install_bin)/dylan-tool
link_source     = $(DYLAN)/bin/dylan

build:
	dylan-compiler -build dylan-tool

install: build
	mkdir -p $(install_bin)
	mkdir -p $(install_lib)
	cp _build/bin/dylan-tool $(install_bin)/
	cp -r _build/lib/lib* $(install_lib)/
	mkdir -p $(DYLAN)/bin
	@if [ ! -L "$(link_source)" ]; then \
	  ln -s $(link_target) $(link_source); \
	fi;

clean:
	rm -rf _build

distclean: clean
	rm -rf $(install_dir)
	rm -f $(link_source)
