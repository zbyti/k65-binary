function add_kernel(fn,tmin,tmax,nc)
{
ker_fn[n_kernels]=fn;
ker_tmin[n_kernels]=tmin;
ker_tmax[n_kernels]=tmax;
ker_nc[n_kernels]=nc;
n_kernels++;
}

function scaninfo()
{
	printf("\n");
	printf("%-38s// SCANLINE %d\n","",scanline);
	printf("\n");
}

function ins_raw(line,nc,expl)
{
	scanline = sprintf("%d",scanpos/76)+0;
	start = sprintf("s%d %2d",scanline,scanpos-76*scanline);
	scanpos += nc;
	scanline = sprintf("%d",scanpos/76)+0;
	printf("    %-34s// [%s] %+3d = s%d %2d  %s\n",line,start,nc,scanline,scanpos-76*scanline,expl);
}

function do_kernel()
{
	ins_raw(ker_fn[kerdone],ker_nc[kerdone],"-k" kerdone "-");
	ker_tmin[kerdone] += 76;
	ker_tmax[kerdone] += 76;
	kerdone++;
	if(kerdone>=n_kernels)
		kerdone = 0;
}

function kertest(nc)
{
	if(scanpos>=ker_tmin[kerdone])
	{
		do_kernel();
		return 1;
	}

	if(scanpos+nc>ker_tmax[kerdone])
	{
		w8 = ker_tmin[kerdone]-scanpos;
		ins_raw("*" w8,w8,"-w-");
		do_kernel();
		return 1;
	}
	return 0;
}

function ins(line,nc,expl)
{
	while(kertest(nc)) {}
	ins_raw(line,nc,expl);
}

function ring(x,y)	{ x+=.5; y-=8.5; return (atan2(y,x)/(2*pi)+1)*256*4; }
function ray(x,y)	{ x+=.5; y-=8.5; return 32*256/(8+sqrt(x*x+y*y)); }

function ringval(x,y)
{
	v=ring(x,y);
	p=ring(x-1,y);
	if(x==0) p=0;
	return and(v-p,0xFF);
}

function rayval(x,y)
{
	v=ray(x,y);
	p=ray(x-1,y);
	if(x==0) p=0;
	return and(v-p,0xFF);
}

function make_tables() {
pi = atan2(0,-1);

for(x=0;x<16;x++)
{
	printf("data TunRing" x " {\n\talign 32\n\t");
	for(y=0;y<18;y++) printf("%d ",ringval(x,y));
	print "\n}";
}

for(x=0;x<16;x++)
{
	printf("data TunRay" x " {\n\talign 32\n\t");
	for(y=0;y<19;y++) printf("%d ",rayval(x,y));
	print "\n}";
}
}

function make_offscreen() {

	print "func tunoff {";
	print "\ta=px1";
	for(i=0;i< 8;i++) print "\ta+TunRing" i ",y a?0x80 tmp3>>>";
	for(i=8;i<16;i++) print "\ta+TunRing" i ",y a?0x80 tmp4>>>";
	print "\ta=py1";
	for(i=0;i< 8;i++) print "\ta+TunRay" i ",y a?0x80 tmp5>>>";
	for(i=8;i<16;i++) print "\ta+TunRay" i ",y a?0x80 tmp6>>>";

	print "\ta=tmp3 a^tmp5 frambuff+32,x=a";
	print "\ta=tmp4 a^tmp6 frambuff,x=a";
	print "}";
}



BEGIN{

make_tables();
make_offscreen();

n_kernels=0;
#add_kernel("cbg=a=(txtc),x",0,13,8);
add_kernel("pf1=y=frambuff,x",0,21-1,7);
add_kernel("pf1=y=tmp7",35,53,7);

scanpos = 6;
kerdone = 0;

print "func scanliner3 {";

ins("x++",2,"");
ins("gp0=y=frambuff+32,x",7,"");
ins("a=px1",3,"start X computation");
for(i=0;i<8;i++) ins("a+TunRing" i ",x a?0x80 tmp3<<<",11,"do X");
for(i=0;i<8;i++) ins("a+TunRing" (i+8) ",x a?0x80 tmp4>>>",11,"do X");
ins("a=py1",3,"start Y computation");
for(i=0;i<8;i++) ins("a+TunRay" i ",x a?0x80 tmp5<<<",11,"do Y");
for(i=0;i<8;i++) ins("a+TunRay" (i+8) ",x a?0x80 tmp6>>>",11,"do Y");
ins("a=tmp3 a^tmp5 gp1=a",9,"finalize 1");
ins("a=tmp4 a^tmp6 tmp7=a",9,"finalize 2");

#ins("cbg=a=0xDA",5,""); ins("*9",9,"");
ins("a=dfx1 c-",5,""); ins("a+TunCol,x cbg=a *2",9,"");

ins("x?17",2,"");
ins("",0,"");

print "}";

}