VC=v

build: clean
	$(VC) -g build . >> /dev/null

clean:
	find . -name '*_test' | xargs rm -f 
	rm -rf *.o *.o.tmp*

test: 
	./bin/test

fmt:
	./bin/fmt
