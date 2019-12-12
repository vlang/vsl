VC=v
modules := const quaternion

build: clean
	$(foreach module, $(modules), $(VC) -g build module ./vsl/$(module);)

clean:
	rm -rf test vsl.o

test: build
	$(VC) -g run test.v
