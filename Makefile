all: gitmodules menuconfig

gitmodules: 
	@echo "Updating modules";
	git submodule update --init

menuconfig: 
	@echo "Opening kconfig menu"
	( \
	mkdir -p build;\
	cd build;\
	srctree=$(shell pwd) BOARD_DIR=boards/** $(shell pwd)/kconfig/kconfig/menuconfig.py Kconfig; \
	cmake ..; \
	)	

.PHONY: build
build: 
	( \
		cd build; \
		make -j$(nproc); \
	)

clean: 
	rm -rf build 
