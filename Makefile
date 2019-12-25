VC=v

build: clean
	$(VC) -g build vsl >> /dev/null

clean:
	rm -rf test *.o *.o.tmp*

test: 
	./bin/test
