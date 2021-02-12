all: gitmodules menuconfig

gitmodules: 
	@echo "Updating modules";
	git submodule update --init

menuconfig: 
	@echo "Opening kconfig menu"
	( \
	mkdir -p bin ;\
	cd bin ;\
	srctree=$(shell pwd) BOARD_DIR=boards/** $(shell pwd)/kconfig/kconfig/menuconfig.py Kconfig; \
	cmake ..; \
	)	


clean: 
	rm -rf bin
