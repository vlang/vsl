VC=v

build: clean
	$(VC) -g build . >> /dev/null

clean:
	find . -name '*_test' | xargs rm -f 
	rm -rf *.o *.o.tmp*

test: 
	v test .
	find . -name '*_test' | xargs rm -f 

format:
	v -g test .
