#!/bin/perl

@v = ();
while (<>) {
	push @v, hex((split / /)[0]);
}

for ($i=1; $i<$#v; $i++) {
	printf "%d\n", ($v[$i]-$v[$i-1]);
}
