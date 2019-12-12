VC=v

build: clean
        $(VC) -g build module $(PWD)/vsl

clean:
        rm -rf test vsl.o

test: build
        $(VC) -g run test.v
