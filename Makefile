all: gitmodules prepare build

prepare: 
	if [ ! -f build/config.json ]; then \
		mkdir -p build ;\
		cd build ;\
		srctree=$(shell pwd) BOARD_DIR=boards/** $(shell pwd)/kconfig/kconfig/menuconfig.py Kconfig ;\
		cmake .. ;\
	fi 

gitmodules: 
	@echo "Updating modules";
	if [ ! -f kconfig/kconfig/menuconfig.py ]; then \
		git submodule update --init ;\
	fi 

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
