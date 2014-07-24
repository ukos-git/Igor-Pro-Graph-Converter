#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <Readback ModifyStr>
#include <axis utilities>
#include <Extract Contours As Waves>
#include <Graph Utility Procs>
#include <Percentile and Box Plot>

//Requires Igor 6.1 or later for /FREE waves

static function DiscreteColorTable(ctab)
	string ctab
	//Returns 1 if the colortable ctab is in this list, meaning that it is discrete and should not be interpolated
	//Users may add the wave name of their own discrete color tables to the list to avoid Plotly doing interpolation.
	
	variable discrete = 0
	string discreteList = "Grays16;Rainbow16;Geo32;LandAndSea8;Relief19;PastelsMap20;Bathymetry9;Fiddle;GreenMagenta16;EOSOrangeBlue11;EOSSpectral11;dBZ14;dBZ21;Web216;Classification"
	if (findlistitem(ctab,discreteList)>-1)
		discrete = 1
	endif
	return discrete
end

static function Mrk2Px(MrkSize) //Returns screen pixels size for markers given and igor marker size
// MARKERS, the formula is px=NearestOdd(2*IgorSize*screenresolution/72 - 1).   
	variable MrkSize
	//Return NearestOdd(2*MrkSize*screenresolution/72 - 1)
	return MrkSize
end

static Function Txt2Px(PtSize)  //Returns screen px size given an igor text point size
// For text, we have px=floor(pt*screenresolution/72) = floor(pt*4/3)
	variable PtSize
	return floor(ptSize*screenresolution/72) 
end

static function NearestOdd(num)
	variable num
	return (round((num+1)/2))*2-1
end

function ttest()
	string text, fontname
	variable fontsize, oz
	text = "This is te\f02st with \\ some text"
	print text
	print processtext(text,fontname,fontsize,oz)
end

static function/T ProcessText(text,fontName,Fontsize,OZ[,OZval])
	string text, &fontName   //Returns the text cleaned of dangerous backslashes, and returns whatever data Plotly can use
	variable &fontSize, &OZ, OZval		//ypos is the y-value to use if OZ is set.
	variable index = Strsearch(Text,"\F",0)  //Returns position of \F, if there is one.
	string xtra
	if (index>-1) // >0 means we found \F, so there is a font in there
		variable CloseQuote = StrSearch(Text,"'",index+3)
		FontName = Text[index+3,CloseQuote-1]
		Text = ReplaceString("\F'"+FontName+"'",text,"")
	else
		fontName = "default"
	endif
	index = Strsearch(Text,"\Z",0)  //Returns position of \Z, if there is one.
	if (index>-1) // >0 means we found \Z, so there is a font size in there
		Fontsize = Str2num(Text[index+2,index+3])
		Text = ReplaceString("\Z"+Text[index+2,index+3],text,"")
	else
		fontSize = 0 //Make default
	endif
	
	index = strsearch(text,"\OZ",0)
	if (index>-1)
		text = replacestring("\OZ",text,dub2str(OZval))
		OZ = 1
	else
		OZ = 0
	endif
	
	//Now remove unsupported escape codes, at least partially so that at least there is no error
	do 
	index = 1
	index = strsearch(text,"\[",0)
	if (index>-1)
		xtra = text[index,index+2]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)
	
	do 
	index = 1
	index = strsearch(text,"\]",0)
	if (index>-1)
		xtra = text[index,index+2]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)
		
	text = replacestring("\B",text,"",1)
	text = replacestring("\JR",text,"",1)
	text = replacestring("\JC",text,"",1)
	text = replacestring("\JL",text,"",1)
	text = replacestring("\M",text,"",1)
	text = replacestring("\S",text,"",1)
	text = replacestring("\t",text,"",1)
	text = replacestring("\r",text,"",1)
	text = replacestring("\n",text,"",1)

	do 
	index = 1
	index = strsearch(text,"\f",0)
	if (index>-1)
		xtra = text[index,index+3]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = Strsearch(Text,"\K",0)  
	if (index>-1)
		CloseQuote = StrSearch(Text,")",index+1)
		xtra = text[index,CloseQuote]
		Text = ReplaceString(xtra,text,"")
	endif
	while (index>-1)
		
	do 
	index = 1
	index = Strsearch(Text,"\k",0)  
	if (index>-1)
		CloseQuote = StrSearch(Text,")",index+1)
		xtra = text[index,CloseQuote]
		Text = ReplaceString(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = strsearch(text,"\L",0)
	if (index>-1)
		xtra = text[index,index+5]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)
	
	do 
	index = 1
	index = Strsearch(Text,"\$PICT$name=",0)  
	if (index>-1)
		CloseQuote = StrSearch(Text,"$/PICT$",index+1)
		xtra = text[index,CloseQuote+6]
		Text = ReplaceString(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = strsearch(text,"\s",0)
	if (index>-1)
		xtra = text[index,index+5]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = strsearch(text,"\W",0)
	if (index>-1)
		xtra = text[index,index+4]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	

	do 
	index = 1
	index = strsearch(text,"\X",0)
	if (index>-1)
		xtra = text[index,index+2]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = strsearch(text,"\x",0)
	if (index>-1)
		xtra = text[index,index+4]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	

	do 
	index = 1
	index = strsearch(text,"\Y",0)
	if (index>-1)
		xtra = text[index,index+2]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	

	do 
	index = 1
	index = strsearch(text,"\y",0)
	if (index>-1)
		xtra = text[index,index+4]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	

	do 
	index = 1
	index = strsearch(text,"\Zr",0)
	if (index>-1)
		xtra = text[index,index+5]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	

	do 
	index = 1
	index = strsearch(text,"\Z",0)
	if (index>-1)
		xtra = text[index,index+3]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = strsearch(text,"\O",0)  //Note, we already removed \OZ, which means something to us.
	if (index>-1)
		xtra = text[index,index+2]
		text = replacestring(xtra,text,"")
	endif
	while (index>-1)	
	
	do 
	index = 1
	index = strsearch(text,"\{",0)
	if (index>-1)
		CloseQuote = StrSearch(Text,"}",index+1)
		xtra = text[index,CloseQuote]
		Text = ReplaceString(xtra,text,"")
	endif
	while (index>-1)	
	
	//If the user's string has a" in  it, the text ends there, but I can't figure out how to fix it.  At least it doesn't crash.
	
	
	 text = replacestring("\\",text,"",1)  //Get rid of any \ just in case we missed any escape codes. 
	return text
end	

static function/T ExtractFont(Text)
	string &Text   //Note the  pointer...we will actually extract the control sequence!
	string FontName
	variable index = Strsearch(Text,"\F",0)  //Returns position of \F, if there is one.
	if (index>-1) // >0 means we found \F, si there is a font in there
		variable CloseQuote = StrSearch(Text,"'",index+3)
		FontName = Text[index+3,CloseQuote-1]
		Text = ReplaceString("\F'"+FontName+"'",text,"")
		return FontName
	else
		return ""		
	endif
end

static function ExtractFontSize(Text)
	string &Text   //Note the  pointer...we will actually extract the control sequence!
	variable FontSize
	variable index = Strsearch(Text,"\Z",0)  //Returns position of \Z, if there is one.
	if (index>-1) // >0 means we found \Z, so there is a font size in there
		Fontsize = Str2num(Text[index+2,index+3])
		Text = ReplaceString("\Z"+Text[index+2,index+3],text,"")
		return Fontsize
	else
		return 0	
	endif
end

static function/T dub2str(num)  //Returns a properly formated Plotly string for numbers up to double precision (15 sig figs).
	variable num
	string s 
	if(!numtype(num) ) //Legal number
		sprintf s,"%.15g", num
	else
		s = "\"NaN\""
	endif
	return replacestring("+",s,"")	
end

static function/T WaveToJSONArray(w)
	wave w
	variable len = dimsize(w,0)
	string o = "[\r"
	variable i = 0
	do
		o += dub2str(w[i])+",\r"
		i += 1
	while (i < len)
	o = o[0,strlen(o)-3]
	o += "\r]"
	return o
end

static function/T txtWaveToJSONArray(w)
	wave/T w
	variable len = dimsize(w,0)
	string o = "[\r"
	string fontName=""
	variable FontSize=0
	variable OZ = 0
	variable i = 0
	do
		o += "\""+ ProcessText(w[i],fontName,Fontsize,OZ)+"\",\r"
		i += 1
	while (i < len-1)
	o +=  "\""+ProcessText(w[i],fontName,Fontsize,OZ)+"\"\r]"
	return o
end

static function/T Wave2DToJSONArray(w,AxisIsSwapped)
	wave w
	variable AxisIsSwapped
	variable xlen,ylen,i,j
	string o
	if (AxisIsSwapped)
		xlen = dimsize(w,1)
		ylen = dimsize(w,0)
		o = "[\r"
		i = 0
		j = 0
		do
			o += "[\r"
			do
				o += dub2str(w[j][i])+",\r"
				i += 1
			while (i < xlen)
			i = 0
			j += 1
			o = o[0,strlen(o)-3]
			o += "\r],\r"
		while (j < ylen)
	else
		xlen = dimsize(w,0)
		ylen = dimsize(w,1)
		o = "[\r"
		i = 0
		j = 0
		do
			o += "[\r"
			do
				o += dub2str(w[i][j])+",\r"
				i += 1
			while (i < xlen)
			i = 0
			j += 1
			o = o[0,strlen(o)-3]
			o += "\r],\r"
		while (j < ylen)
	endif
	
	o = o[0,strlen(o)-3]
	o += "\r]"
	return o
end

static Function/T AssignLineStyle(lineStyle) //Set the line dash style
	variable linestyle
	if (lineStyle == 0) 
		return ("solid")
	elseif(linestyle == 1)
		return ("1px,1px")
	elseif(linestyle == 2)
		return ("2px,2px")
	elseif(linestyle == 3)
		return ("4px,4px")
	elseif(linestyle == 4)
		return ("1px,2px,3px,2px")
	elseif(linestyle == 5)
		return ("6px,4px,2px,4px")		
	elseif(linestyle == 6)
		return ("7px,2px,2px,2px,2px,2px")	
	elseif(linestyle == 7)
		return ("6px,6px")	
	elseif(linestyle == 8)
		return ("10px,10px")
	elseif(linestyle == 9)
		return ("10px,6px,3px,6px")								
	elseif(linestyle == 10)
		return ("10px,6px,3px,6px,3px,6px")								
	elseif(linestyle == 11)
		return ("5px,2px")								
	elseif(linestyle == 12)
		return ("33px,2px,5px,2px")								
	elseif(linestyle == 13)
		return ("33px,2px,5px,2px,5px,2px")								
	elseif(linestyle == 14)
		return ("33px,2px,5px,2px,5px,2px,5px,2px")								
	elseif(linestyle == 15)
		return ("24px,3px,24px,2px,5px,2px")								
	elseif(linestyle == 16)
		return  ("24px,3px,24px,2px,5px,2px,5px,2px")
	elseif(linestyle == 17)
		return  ("24px,3px,24px,2px,5px,2px,5px,2px,5px,2px")
	endif	
end

static Function/T AssignMarkerName(MrkrNum,mFill)
	variable MrkrNum, &mFill //Pointer returns new value of mFill
	String PlyMrkr = "square"
	//"'dot' | 'cross' | 'diamond' | 'square' | 'triangle-down' | 'triangle-left' | 'triangle-right' | 'triangle-up' | 'x'", 
	
//0"circle"
//1"square"
//2"diamond"
//3"cross"
//4"x"
//5"triangle-up"
//6"triangle-down"
//7"triangle-left"
//8"triangle-right"
//9"triangle-ne"
//10"triangle-se"
//11"triangle-sw"
//12"triangle-nw"
//13"pentagon"
//14"hexagon"
//15"hexagon2"
//16"octagon"
//17"star"
//18"hexagram"
//19"star-triangle-up"
//20"star-triangle-down"
//21"star-square"
//22"star-diamond"
//23"diamond-tall"
//24"diamond-wide"
//25"hourglass"
//26"bowtie"
//27"circle-cross"
//28"circle-x"
//29"square-cross"
//30"square-x"
//31"diamond-cross"
//32"diamond-x"
//33"cross-thin"
//34"x-thin"
//35"asterisk"
//36"hash"
//37"y-up"
//38"y-down"
//39"y-left"
//40"y-right"
//41"line-ew"
//42"line-ns"
//43"line-ne"
//44"line-nw"
	switch(MrkrNum)
		case 0: //plus
			PlyMrkr = "cross-thin"
			mFill = 0
			break
		case 1: //x
			PlyMrkr = "x-thin"
			mFill=0
			break
		case 2: //*
			PlyMrkr = "asterisk"
			mFill=0
			break
		case 3: 
			PlyMrkr = "hourglass"
			mFill=0
			break
		case 4:
			PlyMrkr = "bowtie"
			mFill =0
			break
		case 5:
			PlyMrkr = "square"
			break
		case 6:
			PlyMrkr = "triangle-up"
			break
		case 7:
			PlyMrkr = "diamond"
			break
		case 8:
			PlyMrkr = "dot"
			break
		case 9: //hline
			PlyMrkr = "line-ew"
			break
		case 10: //vline
			PlyMrkr = "line-ns"
			break
		case 11: //plusbox
			PlyMrkr = "square-cross"
			break
		case 12: //xbox
			PlyMrkr = "square-x"
			break
		case 13: //dotbox
			PlyMrkr = "square-dot"
			break
		case 14: //hourglass
			PlyMrkr = "hourglass"; mFill=1
			break
		case 15: //x-wing
			PlyMrkr = "bowtie"; mFill=1
			break
		case 16: //box
			PlyMrkr = "square"; mFill=1
			break
		case 17: //triangle-up
			PlyMrkr = "triangle-up"; mFill=1
			break
		case 18: //diamond
			PlyMrkr = "diamond"; mFill=1
			break
		case 19: //circle
			PlyMrkr = "dot"; mFill=1
			break
		case 20: //slash
			PlyMrkr = "line-ne"
			break
		case 21:
			PlyMrkr = "line-nw"; mFill=0
			break
		case 22:
			PlyMrkr = "triangle-down"; mFill=0
			break
		case 23:
			PlyMrkr = "triangle-down"; mFill=1
			break
		case 24:
			PlyMrkr = "triangle-down-dot"; mFill=0
			break
		case 25:
			PlyMrkr = "diamond-wide"; mFill=0
			break
		case 26:
			PlyMrkr = "diamond-wide"; mFill=1
			break
		case 27:
			PlyMrkr = "diamond-wide-dot"; mFill=0
			break
		case 28:
			PlyMrkr = "diamond-tall"; mFill=0
			break
		case 29:
			PlyMrkr = "diamond-tall"; mFill=1
			break
		case 30:
			PlyMrkr = "diamond-tall-dot"; mFill=0
			break
		case 31:
			PlyMrkr = "triangle-sw"; mFill=0
			break
		case 32:
			PlyMrkr = "triangle-sw"; mFill=1
			break
		case 33:
			PlyMrkr = "triangle-se"; mFill=0
			break
		case 34:
			PlyMrkr = "triangle-se"; mFill=1
			break
		case 35:
			PlyMrkr = "triangle-ne"; mFill=0
			break
		case 36:
			PlyMrkr = "triangle-ne"; mFill=1
			break
		case 37:
			PlyMrkr = "triangle-nw"; mFill=0
			break
		case 38:
			PlyMrkr = "triangle-nw"; mFill=1
			break
		case 39:
			PlyMrkr = "hash"; mFill=0
			break
		case 40:
			PlyMrkr = "diamond-dot"; mFill=0
			break
		case 41:
			PlyMrkr = "circle-dot"; mFill=0
			break
		case 42:
			PlyMrkr = "circle-cross"; mFill=0
			break
		case 43:
			PlyMrkr = "circle-x"; mFill=0
			break
		case 44:
			PlyMrkr = "triangle-up-dot"; mFill=0
			break
		case 45:
			PlyMrkr = "triangle-left"; mFill=0
			break
		case 46:
			PlyMrkr = "triangle-left"; mFill=1
			break
		case 47:
			PlyMrkr = "triangle-left-dot"; mFill=0
			break
		case 48:
			PlyMrkr = "triangle-right"; mFill=0
			break
		case 49:
			PlyMrkr = "triangle-right"; mFill=1
			break
		case 50:
			PlyMrkr = "triangle-right-dot"; mFill=0
			break
		case 51:
			PlyMrkr = "pentagon"; mFill=0
			break
		case 52:
			PlyMrkr = "pentagon"; mFill=1
			break
		case 53:
			PlyMrkr = "pentagon-dot"; mFill=0
			break
		case 54:
			PlyMrkr = "hexagon"; mFill=0
			break
		case 55:
			PlyMrkr = "hexagon"; mFill=1
			break
		case 56:
			PlyMrkr = "hexagon-dot"; mFill=0
			break
		case 57:
			PlyMrkr = "star-triangle-up"; mFill=0
			break
		case 58:
			PlyMrkr = "star-triangle-up"; mFill=1
			break
		case 59:
			PlyMrkr = "star-diamond"; mFill=0
			break
		case 60:
			PlyMrkr = "star-diamond"; mFill=1
			break
		case 61:
			PlyMrkr = "star-square"; mFill=0
			break
		case 62:
			PlyMrkr = "star-square"; mFill=1
			break
	endswitch
	return PlyMrkr
end

static function/T GoodName(name)
	string name
	variable HasFolder = strsearch(name,":",0)
	if (HasFolder < 0) //No data folders
		name = replacestring("'",name,"")
	endif
	return (name)
end
	

static function/T zSizeArray(SizeInfo,SizeCode)  
	//This function outputs everything needed after "size": to do an array of sizes
	
	string SizeInfo
	variable SizeCode //For markers we need size*2+1, for text markers we need *3.  This code tells us what we have. 
	//Actually, if we give Igor a marker size x, igor plots a marker that s 2x+1 point, or (2x+1)*4/3 px becuase 12pt=16px.
	//Actually, px = pt * screenresolution/72, whic is the same thing mostly, but we should be a general as possible, so this is better
	string o=""
	string szWave = stringFromList(0,SizeInfo,",")
	variable zMin = str2num(stringFromList(1,SizeInfo,","))
	variable zMax =str2num(stringFromList(2,SizeInfo,","))
	variable mrkmin =str2num(stringFromList(3,SizeInfo,","))
	variable mrkmax =str2num(stringFromList(4,SizeInfo,","))
	variable i
	
//	szwave = replacestring("'",szwave,"")
	szwave = goodname(szwave)
	duplicate/o/FREE $szWave zWave
	variable NumSizes = dimsize(zWave,0)
	variable val 
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize
	
	make/O/FREE/N=2 SizeWave
	wavestats/Q $szWave
	variable zmn, zmx, mkmn, mkmx
	if (!numtype(zmin))
		zmn = zmin
	else 
		zmn = v_min
	endif
	if (!numtype(zmax))
		zmx = zmax
	else 
		zmx = v_max		
	endif
	setscale/I x zmn,zmx,"" SizeWave
	SizeWave[0] = mrkmin
	SizeWave[1] = mrkMax
	print "Markers", MrkMin, MrkMAx
	i=0
	o += "[\r"
	do
		if (zWave[i] < zmn)  //This if statement handles marker sizes less than min and max.
			val = zmn
		elseif (zWave[i] > zmx)
			val = zmx
		else
			val = zWave[i]
		endif
		variable PxSize
		if (sizeCode==2) //Markers
			pxSize = 2*Mrk2Px(sizewave(val))*screenresolution/72
		else //Text
			pxSize = Txt2Px(sizewave(val))
		endif
		o += dub2str(pxSize)+",\r"
		If (pxSize > LargestMarkerSize)
		 	LargestMarkerSize = pxSize  //Have to keep of largest marker in the graph, in PX!
		 endif
		i += 1
	while (i < numSizes)
	 o = o[0,strlen(o)-3] //Remove the comma after the last data value\
	 o += "\r]"
	 return o
end

static function/T CreateColorTab(colorinfo,zwave[,cindex])
	string colorinfo,cindex
	wave zwave
	variable index = 0
	if (paramisdefault(cindex))  //We have a color table, not a color index
		variable zMin = str2num(stringFromList(0,Colorinfo,","))
		variable zMax =  str2num(stringFromList(1,Colorinfo,","))
		string ctName =  stringFromList(2,Colorinfo,",")
		variable ReverseMode =  str2num(stringFromList(3,Colorinfo,","))
		ColorTab2Wave $ctName  //Makes a Nx43 matrix for RGB name M_colors
		wave m_colors=m_colors
		variable discrete = DiscreteColorTable(ctName)
	else  //We have a color index
		wavestats/Q zwave
		zMin = v_min
		zMax = v_max
//		cindex = replacestring(" ",cindex,"")
		cindex = goodname(cindex)
		duplicate/FREE $cindex ciwave
		//ciwave = replacestring ("'",ciwave,"")
		duplicate/o ciwave m_colors
		discrete = 1   //A color index is always discrete
		index = 1
	endif
//	IgorNB(colorinfo+"\r\r")
	variable numColors = dimsize(m_colors,0)
	m_colors /= 257 //Plotly is 8-bit
	variable i ,j

	string o = "\"colorscale\":[\r" //get ready to write the color scale
	if (reversemode)
		i = 0
		do
			j = (numcolors-1)-i
			o += "["+dub2str(j/(numColors-1))+",\"rgb("+dub2str(M_colors[i][0])+","+dub2str(M_colors[i][1])+","+dub2str(M_colors[i][2])+")\"],\r"
			if (discrete && (i < numcolors-1)) //Make the color table explicitly discrete colors, even in Plotly interpolates
				o += "["+dub2str((j-1)/(numColors-1))+",\"rgb("+dub2str(M_colors[i][0])+","+dub2str(M_colors[i][1])+","+dub2str(M_colors[i][2])+")\"],\r"
			endif
			i += 1
		while(i < numcolors)
	else
		i = 0
		do
			o += "["+dub2str(i/(numColors-1))+",\"rgb("+dub2str(M_colors[i][0])+","+dub2str(M_colors[i][1])+","+dub2str(M_colors[i][2])+")\"],\r"
			if (discrete && (i < numcolors-1)) //Make the color table explicitly discrete colors, even in Plotly interpolates
				o += "["+dub2str((i+1)/(numColors-1))+",\"rgb("+dub2str(M_colors[i][0])+","+dub2str(M_colors[i][1])+","+dub2str(M_colors[i][2])+")\"],\r"
			endif
			i += 1
		while(i < numcolors)
	endif
	o = o[0,strlen(o)-3]
	o += "\r],\r"
	wavestats/Q zwave
	variable zlo, zhi
	if (!numtype(zmin))
		zlo = zmin
	else
		zlo = V_min
	endif
	if (!numtype(zmax))
		zHi = zmax
	else
		zHi = V_Max
	endif
	zmin = zlo
	zmax = zhi
	o += "\"zmin\":"+dub2str(zmin)+",\r"
	o += "\"zmax\":"+dub2str(zmax)+",\r"
	o += "\"zauto\":false,\r"
	return o
//	Logarithmic Indexed Color
//	For logarithmic indexed color (the ModifyImage log parameter is set to 1), colors are mapped using the log(x scaling) and log(image z) values this way:
//	colorIndexWaveRow = floor(nRows*(log(zImageValue)-log(xMin))/(log(xmax)-log(xMin)))
//	where,
//	nRows = DimSize(colorIndexWave,0)
//	xMin = DimOffset(colorIndexWave,0)
//	xMax = xMin + (nRows-1) * DimDelta(colorIndexWave,0)
//	Displaying image data in log mode will be slower than in linear mode.
end

static function/T zColorArray(colorinfo,mode[,transp])
	//This function outputs everything needed after "color": to do an array of colors.
	string colorinfo
	string mode //This is required because text graphs aren't compatible with colorscales
	variable transp  //An optional parameter to set the transparency.
	if (paramisdefault(transp))
		transp = 1
	endif
	string o= ""
	string szWave = stringFromList(0,Colorinfo,",")
	variable  zMin = str2num(stringFromList(1,Colorinfo,","))
	variable zMax =  str2num(stringFromList(2,Colorinfo,","))
	string ctName =  stringFromList(3,Colorinfo,",")
	string ReverseMode =  stringFromList(4,Colorinfo,",")
	string ciWave = stringFromList(5,Colorinfo,",")
	variable i, val
//	szWave = replacestring("'",szWave,"") // Need to remove quotes from "possibly quote" name in functions.
	szWave = goodname(szWave)
	duplicate/o/FREE $szWave zWave 
	variable NumColors = dimsize(zWave,0)
	if (stringmatch(ctName,"cindexRGB") )
		Print "COLOR ERROR : cindex"
	elseif(stringmatch(ctName,"directRGB") )
		print "COLOR ERROR : directRBG"
	else //We have a color table
	//	if ( strsearch(Mode,"text",0)>-1 ) // We are working with a text graph, so do an explicit color list only, not a colorscale
			ColorTab2Wave $ctName  //Makes a Nx43 matrix for RGB name M_colors
			wave m_colors = m_colors
			numColors = dimsize(zwave,0)	//Make a color entry for each point
			m_colors /= 257 //Plotly is 8-bit
			wavestats/Q $szWave
			variable zmn, zmx, mkmn, mkmx
			if (!numtype(zmin))
				zmn = zmin
			else 
				zmn = v_min
			endif
			if (!numtype(zmax))
				zmx = zmax
			else 
				zmx = v_max		
			endif
			
			duplicate/o m_colors m_test
			if (str2num(ReverseMode)==1)
				setscale/I x zmx,zmn,"" m_colors
			else
				setscale/I x zmn,zmx,"" m_colors
			endif
			i = 0
			o += "[\r"
			
			do
				
				if (zWave[i] < zmn)  //This if statement handles color sizes less than min and max.
					val = zmn
				elseif (zWave[i] > zmx)
					val = zmx
				else
					val = zWave[i]
				endif
				o += "\"rgba("+dub2str(interp2d(m_colors,val,0))+","+dub2str(interp2d(m_colors,val,1))+","+dub2str(interp2d(m_colors,val,2))+","+dub2str(transp)+")\",\r"
				i += 1
			while ( i < numColors)
			o = o[0,strlen(o)-3] //Remove the comma after the last data value
			o += "\r]"
//---All the following is commented for now...lets just send the colors explicityly instead of sending a color table.----------------
//---The following code works, but needs to handle reverse mode.

	//	else  //Create a list of z-values and a color table.
	//		ColorTab2Wave $ctName  //Makes a Nx43 matrix for RGB name M_colors
	//		//First, output an array of z-values
	//		i = 0
	//		o += "[\r"
	//	
	//		do
	//		 	o += dub2str(zwave[i])+",\r"
	//		 	i += 1
	//		 while (i < NumColors)
	//		 o = o[0,strlen(o)-3] //Remove the comma after the last data value
	//	
	//		numColors = dimsize(m_colors,0)
	//		m_colors /= 257 //Plotly is 8-bit
	//		i = 0
	//		o += "\r],\r\"colorscale\":[\r" //get ready to write the color scale
	//		do
	//			o += "["+dub2str(i/(numColors-1))+",\"rgb("+dub2str(M_colors[i][0])+","+dub2str(M_colors[i][1])+","+dub2str(M_colors[i][2])+")\"],\r"
	//			i += 1
	//		while(i < numcolors)
	//		if (!numtype(str2num(zmin)))
	//			o += "\"zmin\":"+zmin+",\r"
	//		endif
	//		if (!numtype(str2num(zmax)))
	//			o += "\"zmax\":"+zmax+",\r"
	//		endif
	//		o = o[0,strlen(o)-3]
	//		o += "\r]"
	//		
	//	endif
	endif
	return o
end	

static function/T CreateContourObj(contour,graph)
	string contour,graph
	string info = contourinfo(graph, contour,0)
//	IgorNB(info+"\r\r")
	string obj = "{\r"

//Sort out the axes---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	string XAxis = stringbykey("XAXIS",info,":",";",1)  //Get the name of the x-axis, but in Igor this does not have to be horizontal
	string YAxis = stringbykey("YAXIS",info,":",";",1) //Get the name of the y-axis, but in Igor this does not have to be vertical
	string AxisFlags = stringbykey("AXISFLAGS",info,":",";",1)
	string Lnam = stringByKey("L",AxisFlags,"=","/",1)
	string Tnam = stringByKey("T",AxisFlags,"=","/",1)
	string Rnam = stringByKey("R",AxisFlags,"=","/",1)
	string Bnam = stringByKey("B",AxisFlags,"=","/",1)
	variable rgbR,rgbG,rgbB
	variable setlinecolor=0

	//Look out for axis swap and add names of axes to a vertical and horizontal list
	variable axisISswapped = 0
	if (stringmatch(Xaxis,"right") || stringmatch(Xaxis,"left") || stringmatch(Xaxis,Lnam) || stringmatch(Xaxis,Rnam))
		//The axes are swapped because the x-data are plotted along a vertical axis.
		axisISswapped = 1
		variable HaxNum = whichlistitem(YAxis,Haxislist) 	 //This returns a number from the list, -1 if the axis name has not yet been used.
		variable Vaxnum = whichlistitem(XAxis,Vaxislist)		 //This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum<0)  //The axis has not already been used, write it to the local list of horizontal-axes
			Haxislist += yAxis+";"
			HaxNum = whichlistitem(yAxis,HaxisList)
		endif
		if(VaxNum<0)  //The axis has not already been used, write it to the local list of vertical-axes
			Vaxislist += xAxis+";"
			VaxNum = whichlistitem(xAxis,VaxisList)
		endif
	else //axes not swapped.
		HaxNum = whichlistitem(XAxis,HaxisList)			 //This returns a number from the list, -1 if the axis name has not yet been used.
		VaxNum = whichlistitem(YAxis,VaxisList)			 //This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum<0)  //The axis has not already been used, write it to the local list of x-axes
			Haxislist += xAxis+";"
			HaxNum = whichlistitem(XAxis,HaxisList)
		endif
		if(VaxNum<0)  //The axis has not already been used, write it to the local list of y-axes
			Vaxislist += yAxis+";"
			VaxNum = whichlistitem(YAxis,VaxisList)
		endif
	endif
	
	//Now, write the horizontal and vertical axis number to plotly, unless it is the first instance, in which case write nothing.
	if (HaxNum > 0)
		obj += "\"xaxis\":\"x"+dub2str(HaxNum+1)+"\",\r"   //If igor axis number is >0, write plotly axis number >1 
	else
//		obj +=  "\"xaxis\":\"x\",\r"	//First x-axis, plotly standard name, no number.  Don't write it, it is default.
	endif
	if (VaxNum > 0)
		obj += "\"yaxis\":\"y"+dub2str(VaxNum+1)+"\",\r"   //If igor axis number is >0, write plotly axis number >1 
	else
//		obj +=  "\"yaxis\":\"yaxis\",\r"	//First y-axis, plotly standard name, no number.  Don't write it, it is default.
	endif
//Done sorting out axes------------------------------------------------------------------------------------------------------------------------------------------------
//Get the data------------------------------------------------------
	string xwave = stringbykey("XWAVEDF",info,":",";",1)+stringbykey("XWAVE",info,":",";",1) 
//	string Xdf = stringbykey("XWAVEDF",info,":",";",1)
	string ywave = stringbykey("YWAVEDF",info,":",";",1) + stringbykey("YWAVE",info,":",";",1) 
//	string Ydf = stringbykey("YWAVEDF",info,":",";",1)
	string zwave =  stringbykey("ZWAVEDF",info,":",";",1)+stringbykey("ZWAVE",info,":",";",1)
//	string Zdf = stringbykey("YWAVEDF",info,":",";",1)
	
	variable x0 = DimOffset($Zwave,0)
	variable dx = DimDelta($Zwave,0)
	variable y0 = DimOffset($Zwave,1)
	variable dy = DimDelta($Zwave,1)
	if (stringmatch(xwave,"")) //notplotted against an x-wave
		obj+= "\"x0\":"+dub2str(x0)+",\r"
		obj+= "\"dx\":"+dub2str(dx)+",\r"
	else
		if (axisisswapped)
			obj += "\"y\":" + WaveToJSONArray($(xwave))+",\r"
		else
			obj += "\"x\":" + WaveToJSONArray($(xwave))+",\r"
		endif
	endif
	if (stringmatch(ywave,"")) //notplotted against a y-wave
		obj+= "\"y0\":"+dub2str(y0)+",\r"
		obj+= "\"dy\":"+dub2str(dy)+",\r"
	else
		if (axisisswapped)
			obj += "\"x\":" + WaveToJSONArray($(ywave))+",\r"
		else
			obj += "\"y\":" + WaveToJSONArray($(ywave))+",\r"
		endif
	endif
	obj+= "\"z\":"+Wave2DtoJSONArray($zwave,axisIsSwapped)+",\r"

	//Get the colorscale or color
	variable ctabStart = strsearch(info,"ctabLines",0)
	variable cindexStart = strsearch(info,"cindexLines",0)
	if (ctabstart>-1) // This is a color table contour
		variable ctabR = strsearch(info,";",ctabStart)
		string ctab = info[ctabstart+11,ctabR-2]
		obj += CreateColorTab(ctab,$zWave)
	elseif (cindexStart >-1) //This is a color index contour
		ctabR = strsearch(info,";",cindexstart)
		ctab = info[cindexstart+12,ctabR-1]
		obj += CreateColorTab("Cindex",$zWave,cindex=ctab)
	else //We specify an RGB for the contour.
	 	ctab = stringByKey("rgbLines",info,"=",";",1)
		ctab = "color(x)="+ctab	//Add a key for the standard format for the key searcher
		rgbR = round(GetNumFromModifyStr(ctab,"color","(",0)/257)
		rgbG = round(GetNumFromModifyStr(ctab,"color","(",1)/257)
		rgbB = round(GetNumFromModifyStr(ctab,"color","(",2)/257)	
		SetLineColor = 1
	endif
//Do contour specific things---------------------------------------------------------------------------
	obj += "\"contours\":{\r"
	if (setlinecolor)
		obj += "\"coloring\":\"none\",\r"
	else
		obj += "\"coloring\":\"lines\",\r"
	endif
	obj += "\"showlines\":true,\r"
	string levelslist = stringbykey("LEVELS",info,":",";",1)
	variable NumLevels = itemsinlist(Levelslist,",")
	string FirstLevel = stringfromlist(0,LevelsList,",")
	string SecondLevel = stringfromlist(1,LevelsList,",")
	string LastLevel = stringfromlist(NumLevels-1,LevelsList,",")
	obj += "\"start\":"+FirstLevel+",\r"
	obj += "\"end\":"+LastLevel+",\r"
	obj += "\"size\":"+dub2str(str2num(SecondLevel)-str2num(FirstLevel))+",\r" //Assume the level spacing is even, since that's what Plotly does
	obj = obj[0,strlen(obj)-3]
	obj += "\r},\r" //End of "contours"
	obj += "\"ncontours\":"+dub2str(NumLevels)+",\r"

	obj += "\"line\":{\r"
	if(setlinecolor)
		obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	endif
	obj += "\"width\":1\r"
	obj += "},\r"
	obj += "\"autocontour\":false,\r"	
	obj += "\"type\":\"contour\",\r"
	obj += "\"name\":\""+contour+"\",\r"
//Have to check for colorbars and add them if present, in plotly they are part of the heatmap object------------------------------------------------------------------------------------------------------	
	string list = annotationlist(graph)
	variable index=0
	string AnnotationName
	variable ColorscaleCreated = 0
	string CsObj
	do		//Step through the annotations
		AnnotationName = stringFromList(index,List)
		if (strlen(AnnotationName) == 0)
			break //no more anotations, so move on to next section
		endif
		CSobj = CreateColorScaleObj(AnnotationName,graph,contour) ///the 1 at the end specifies all types of annotation except colorscales, which have to be inserted with the image object
		obj += CSobj
		if (!stringmatch(CSobj,"") ) //We created a colorscale, no need to disable colorscale
			ColorscaleCreated = 1
			endif	
		index += 1
	while (1)
	if (colorscaleCreated == 0)
		obj += "\"showscale\":false,\r"
	endif
	obj = obj[0,strlen(obj)-3]
	obj += "\r}\r"
	return obj
	
	
end
//ContourInfo, ContourNameList(graphNameStr, separatorStr )

static function/T createImageObj(image,graph)
	string image,graph 
	string info = imageinfo(graph, image,0)
//	IgorNB(info+"\r\r")
	string obj = "{\r"

//Sort out the axes---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	string XAxis = stringbykey("XAXIS",info,":",";",1)  //Get the name of the x-axis, but in Igor this does not have to be horizontal
	string YAxis = stringbykey("YAXIS",info,":",";",1) //Get the name of the y-axis, but in Igor this does not have to be vertical
	string AxisFlags = stringbykey("AXISFLAGS",info,":",";",1)
	string Lnam = stringByKey("L",AxisFlags,"=","/",1)
	string Tnam = stringByKey("T",AxisFlags,"=","/",1)
	string Rnam = stringByKey("R",AxisFlags,"=","/",1)
	string Bnam = stringByKey("B",AxisFlags,"=","/",1)

	//Look out for axis swap and add names of axes to a vertical and horizontal list
	variable axisISswapped = 0
	if (stringmatch(Xaxis,"right") || stringmatch(Xaxis,"left") || stringmatch(Xaxis,Lnam) || stringmatch(Xaxis,Rnam))
		//The axes are swapped because the x-data are plotted along a vertical axis.
		axisISswapped = 1
		variable HaxNum = whichlistitem(YAxis,Haxislist) 	 //This returns a number from the list, -1 if the axis name has not yet been used.
		variable Vaxnum = whichlistitem(XAxis,Vaxislist)		 //This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum<0)  //The axis has not already been used, write it to the local list of horizontal-axes
			Haxislist += yAxis+";"
			HaxNum = whichlistitem(yAxis,HaxisList)
		endif
		if(VaxNum<0)  //The axis has not already been used, write it to the local list of vertical-axes
			Vaxislist += xAxis+";"
			VaxNum = whichlistitem(xAxis,VaxisList)
		endif
	else //axes not swapped.
		HaxNum = whichlistitem(XAxis,HaxisList)			 //This returns a number from the list, -1 if the axis name has not yet been used.
		VaxNum = whichlistitem(YAxis,VaxisList)			 //This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum<0)  //The axis has not already been used, write it to the local list of x-axes
			Haxislist += xAxis+";"
			HaxNum = whichlistitem(XAxis,HaxisList)
		endif
		if(VaxNum<0)  //The axis has not already been used, write it to the local list of y-axes
			Vaxislist += yAxis+";"
			VaxNum = whichlistitem(YAxis,VaxisList)
		endif
	endif
	
	//Now, write the horizontal and vertical axis number to plotly, unless it is the first instance, in which case write nothing.
	if (HaxNum > 0)
		obj += "\"xaxis\":\"x"+dub2str(HaxNum+1)+"\",\r"   //If igor axis number is >0, write plotly axis number >1 
	else
//		obj +=  "\"xaxis\":\"x\",\r"	//First x-axis, plotly standard name, no number.  Don't write it, it is default.
	endif
	if (VaxNum > 0)
		obj += "\"yaxis\":\"y"+dub2str(VaxNum+1)+"\",\r"   //If igor axis number is >0, write plotly axis number >1 
	else
//		obj +=  "\"yaxis\":\"yaxis\",\r"	//First y-axis, plotly standard name, no number.  Don't write it, it is default.
	endif
//Done sorting out axes------------------------------------------------------------------------------------------------------------------------------------------------
//Get the data------------------------------------------------------
	string xwave = stringbykey("XWAVEDF",info,":",";",1)+stringbykey("XWAVE",info,":",";",1) 
//	string Xdf = stringbykey("XWAVEDF",info,":",";",1)
	string ywave = stringbykey("YWAVEDF",info,":",";",1) + stringbykey("YWAVE",info,":",";",1) 
//	string Ydf = stringbykey("YWAVEDF",info,":",";",1)
	string zwave =  stringbykey("ZWAVEDF",info,":",";",1)+stringbykey("ZWAVE",info,":",";",1)
//	string Zdf = stringbykey("YWAVEDF",info,":",";",1)
	
	variable x0 = DimOffset($Zwave,0)
	variable dx = DimDelta($Zwave,0)
	variable y0 = DimOffset($Zwave,1)
	variable dy = DimDelta($Zwave,1)
	if (stringmatch(xwave,"")) //notplotted against an x-wave
		obj+= "\"x0\":"+dub2str(x0)+",\r"
		obj+= "\"dx\":"+dub2str(dx)+",\r"
	else
		if (axisisswapped)
			obj += "\"y\":" + WaveToJSONArray($(xwave))+",\r"
		else
			obj += "\"x\":" + WaveToJSONArray($(xwave))+",\r"
		endif
	endif
	if (stringmatch(ywave,"")) //notplotted against a y-wave
		obj+= "\"y0\":"+dub2str(y0)+",\r"
		obj+= "\"dy\":"+dub2str(dy)+",\r"
	else
		if (axisisswapped)
			obj += "\"x\":" + WaveToJSONArray($(ywave))+",\r"
		else
			obj += "\"y\":" + WaveToJSONArray($(ywave))+",\r"
		endif
	endif
	obj+= "\"z\":"+Wave2DtoJSONArray($zwave,axisIsSwapped)+",\r"
	//Get the colorscale
	variable ctabStart = strsearch(info,"ctab",0)
	if (ctabStart > -1) //We DO have a color table
		variable ctabR = strsearch(info,";",ctabStart)
		string ctab = info[ctabstart+7,ctabR-2]
		obj += CreateColorTab(ctab,$zWave)
	else //We do not have a color table, we must have a color index
		ctabstart = strsearch(info,"cindex",0)
		ctabR = strsearch(info,";",ctabstart)
		ctab = info[ctabstart+7,ctabR-1]
		obj += CreateColorTab("Cindex",$zWave,cindex=ctab)
	endif
		
	//	 	Colorinfo = colorinfo[1,strlen(colorinfo)-2]  //Strip off the { }
//	 	RGB_Array = zColorArray(ColorInfo,PlyMode)  
//		zColor={zWave,zMin,zMax,ctName  [,reverseMode  [,ciWave  ] ]} or 0


	obj += "\"type\":\"heatmap\",\r"
	obj += "\"name\":\""+image+"\",\r"
//Have to check for colorbars and add them if present, in plotly they are part of the heatmap object------------------------------------------------------------------------------------------------------	
	string list = annotationlist(graph)
	variable index=0
	string AnnotationName
	variable ColorscaleCreated = 0
	string CsObj
	do		//Step through the annotations
		AnnotationName = stringFromList(index,List)
		if (strlen(AnnotationName) == 0)
			break //no more anotations, so move on to next section
		endif
		CSobj = CreateColorScaleObj(AnnotationName,graph,image) ///the 1 at the end specifies all types of annotation except colorscales, which have to be inserted with the image object
		obj += CSobj
		if (!stringmatch(CSobj,"") ) //We created a colorscale, no need to disable colorscale
			ColorscaleCreated = 1
			endif	
		index += 1
	while (1)
	if (colorscaleCreated == 0)
		obj += "\"showscale\":false,\r"
	endif
	obj = obj[0,strlen(obj)-3]
	obj += "\r}\r"
	return obj
end

static Function AssignMarkerNameArray(MrkNumZwave,MRK_Array,MRK_RGBArray,TraceRGB,UseZColor,RGB_Array,opaque) //Make arrays for color and symbol
	string MrkNumZwave,&Mrk_Array,&MRK_RGBArray,TraceRGB,RGB_Array
	variable opaque, useZcolor
	Mrk_Array = "[\r"
	MRk_RGBArray = "[\r"
//	mrknumzwave = replacestring("'",MrkNumZWave,"")
	mrknumzwave = goodname(mrknumzwave)
	duplicate/o/FREE $MrkNumzWave MrkWave
	//wave MrkWave = $(MrkNumZwave) //MrkNumZwave
	variable len = dimsize(MrkWave,0)
	string PlyMrkr
	variable mFill
	variable i = 0
	string RGB=""
	do
		PlyMrkr = AssignMarkerName(MrkWave[i],mFill)	//Function to assign marker name from the wave 
		Mrk_Array += "\""+ PlyMrkr+"\",\r"
		if (MFill == 0 && !opaque)	//this is an non-filled marker type and not opaque
			Mrk_RGBArray +=  "\"rgba(0,0,0,0)\",\r"
		elseif (MFill == 0 && opaque) //This is a non-filled marker type but it's opaque (white)
			Mrk_RGBArray += "\"rgb(255,255,255)\",\r"
		elseif (UseZColor)  //The marker color is an array
			RGB = stringfromlist(i, RGB_Array, "\r")
			Mrk_RGBArray += RGB + "\r"
		else	//The marker is filled-type, and set by the main trace color
			Mrk_RGBArray += TraceRGB + ",\r"
		endif
		i += 1
	while(i<len)
	Mrk_Array = Mrk_array[0,strlen(Mrk_array)-3]
	Mrk_RGBArray = Mrk_RGBarray[0,strlen(Mrk_RGBarray)-3]
	mrk_Array += "\r]"
	mrk_RGBArray += "\r]"
end

static Function/T CreateTrObj(traceName,graph)
	string TraceName,graph
	string PlyName = traceName
		
	string info = TraceInfo(graph, traceName, 0)
//	IgorNB(info+"\r\r")
	variable  txtMrk
	variable mode=GetNumFromModifyStr(info,"mode","",0)
	string PlyMode
 	variable AutoX=0  //Set this flag to zero assumes user supplied a numeric x-wave
 	variable CategoryPlot = 0 //Assume this graph is not a category plot
	string obj = "{\r"  //Opening bracket for the entire data section.

//Sort-out the Axis Names-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//The strategy is to use Igor axis names in Igor, and plotly axis names (is, x, x2, x3,...
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	NVAR DefaultMarkerSize = root:Packages:Plotly:DefaultMarkerSize //In Igor size, not points	
	NVAR DefaultTextSize = root:Packages:Plotly:DefautTextSize
	NVAR MarkerFlag = root:Packages:Plotly:MarkerFlag
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize
	SVAR BarToMode = root:packages:Plotly:BarToMode
	NVAR catCount = root:packages:Plotly:CatCount	
	NVAR TraceOrderFlag = root:packages:Plotly:TraceOrderFlag
	string XAxis = stringbykey("XAXIS",info,":",";",1)  //Get the name of the x-axis, but in Igor this does not have to be horizontal
	string YAxis = stringbykey("YAXIS",info,":",";",1) //Get the name of the y-axis, but in Igor this does not have to be vertical
	string AxisFlags = stringbykey("AXISFLAGS",info,":",";",1)
	string Lnam = stringByKey("L",AxisFlags,"=","/",1)
	string Tnam = stringByKey("T",AxisFlags,"=","/",1)
	string Rnam = stringByKey("R",AxisFlags,"=","/",1)
	string Bnam = stringByKey("B",AxisFlags,"=","/",1)

	//Look out for axis swap and add names of axes to a vertical and horizontal list
	variable axisISswapped = 0
	if (stringmatch(Xaxis,"right") || stringmatch(Xaxis,"left") || stringmatch(Xaxis,Lnam) || stringmatch(Xaxis,Rnam))
		//The axes are swapped because the x-data are plotted along a vertical axis.
		axisISswapped = 1
		variable HaxNum = whichlistitem(YAxis,Haxislist) 	 //This returns a number from the list, -1 if the axis name has not yet been used.
		variable Vaxnum = whichlistitem(XAxis,Vaxislist)		 //This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum<0)  //The axis has not already been used, write it to the local list of horizontal-axes
			Haxislist += yAxis+";"
			HaxNum = whichlistitem(yAxis,HaxisList)
		endif
		if(VaxNum<0)  //The axis has not already been used, write it to the local list of vertical-axes
			Vaxislist += xAxis+";"
			VaxNum = whichlistitem(xAxis,VaxisList)
		endif
	else //axes not swapped.
		HaxNum = whichlistitem(XAxis,HaxisList)			 //This returns a number from the list, -1 if the axis name has not yet been used.
		VaxNum = whichlistitem(YAxis,VaxisList)			 //This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum<0)  //The axis has not already been used, write it to the local list of x-axes
			Haxislist += xAxis+";"
			HaxNum = whichlistitem(XAxis,HaxisList)
		endif
		if(VaxNum<0)  //The axis has not already been used, write it to the local list of y-axes
			Vaxislist += yAxis+";"
			VaxNum = whichlistitem(YAxis,VaxisList)
		endif
	endif

	//Now, write the horizontal and vertical axis number to plotly, unless it is the first instance, in which case write nothing.
	if (HaxNum > 0)
		obj += "\"xaxis\":\"x"+dub2str(HaxNum+1)+"\",\r"   //If igor axis number is >0, write plotly axis number >1 
	else
//		obj +=  "\"xaxis\":\"x\",\r"	//First x-axis, plotly standard name, no number.  Don't write it, it is default.
	endif
	if (VaxNum > 0)
		obj += "\"yaxis\":\"y"+dub2str(VaxNum+1)+"\",\r"   //If igor axis number is >0, write plotly axis number >1 
	else
//		obj +=  "\"yaxis\":\"yaxis\",\r"	//First y-axis, plotly standard name, no number.  Don't write it, it is default.
	endif
 //Done sorting out the axes------------------------------------------------------------------------------------------------------------------------------------------------------------	

	wave Tempyw = TraceNameToWaveRef(graph,traceName)
	duplicate/o/FREE Tempyw yw  //We do this duplication so that if we change the wave (ie, for cityscape or bar) it doesn't change locally
	variable trLen = dimsize(yw,0) 	
	If (!waveExists(XWaveRefFromTrace(graph,traceName)))  //Not plotted against x-wave, in other words, use igor Wave scaling.
		duplicate/o/FREE yw xw
		xw = x
		AutoX=1
	else
		 wave TempXw = XWaveRefFromTrace(graph,traceName)
		duplicate/O/FREE TempXw xw
	endif
	if(!wavetype(xw)) //The x-wave is not numeric...this is a category plot
		CategoryPlot = 1
	endif
	variable toMode = GetNumFromModifyStr(info,"toMode","",0)
	PlyMode = "bars"
  	switch(mode)
 	//	m =0:	Lines between points.	
	//	m =1:	Sticks to zero.
	//	m =2:	Dots at points.
	//	m =3:	Markers.
	//	m =4:	Lines and markers.
	//	m =5:	Histogram bars.
	//	m =6:	Cityscape.
	//	m =7:	Fill to zero.
	//	m =8:	Sticks and markers.
 		case 0:
 			PlyMode = "lines"
 			break
 		case 2:
 			PlyMode = "markers"  //Igor dots at points
 			break
 		case 3:
 			txtMrk = GetNumFromModifyStr(info,"textMarker","",0)
			if (!numtype(txtMrk)) //txtMrk is a number, meaning there are no text markers in the trace
				PlyMode = "markers"
			else  //We have a text graph
				PlyMode = "text"
			endif
			break
		case 4:
			txtMrk = GetNumFromModifyStr(info,"textMarker","",0)
			if (!numtype(txtMrk)) //txtMrk is a number, meaning there are no text markers in the trace
				PlyMode = "lines+markers"
			else  //We have a text graph
				PlyMode = "lines+text"
			endif
			break
		case 5: //Bars.  But we need to handle it differently if not category plot...instead use cityscape and fill to zero.
			if (categoryplot == 0) //So this is NOT a category plot, so it isn't a plotly bar chart.
				PlyMode = "lines"
				if (AutoX) //We are using Igor scaling, so we need to add an extra point at the end to make the Plotly graph look like the Igor graph
					InsertPoints trLen,1, xw, yw
					xw = x
					yw[trLen] = yw[trLen-1]
					trLen += 1
				endif
				mode = 6
				print "NOTE: Strokes will not be rendered correctly in Plotly.  Consider switching to Igor category mode for more bar chart control."
			else  //This graph has a category plot, it will be a proper Plotly histogram.
				PlyMode = "bar"
				catCount = trLen
				if (stringmatch(BarToMode,"NULL")) //No grouping mode has yet been set for bars. Use the first instance of a bar to set this mode for Plotly, which only allows a global gouping mode
					if (toMode==-1)
						BarToMode = "overlay"
					elseif (toMode==2 || toMode==3)
						BarToMode = "stack"
						TraceOrderFlag = 1	//We have to reverse the order for stacked bars
					else
						BarToMode = "group"
					endif
				endif
			endif
			break
		case 6: //For cityscape, send a lines-only graph, but be sure to set "hv" in lines properties
			PlyMode = "lines"
			if (AutoX) //We are using Igor scaling, so we need to add an extra point at the end to make the Plotly graph look like the Igor graph
				InsertPoints trLen,1, xw, yw
				xw = x
				yw[trLen] = yw[trLen-1]
				trLen += 1
			endif
			break
		case 7: //Fill to zero is a line, no markers, with a fill setting
			PlyMode = "lines"
			break
	endswitch

	if (axisISswapped)
		if (CategoryPlot)
			obj += "\"y\":" + TxtWaveToJSONArray(xw)+",\r"
		elseif(AutoX) //Use Igor Scaling
			obj += "\"y0\":"+dub2str(dimoffset(yw,0))+",\r"
			obj += "\"dy\":"+dub2str(dimdelta(yw,0))+",\r"
		else
			obj += "\"y\":" + WaveToJSONArray(xw)+",\r"
		endif
		obj += "\"x\":"+ WaveToJSONArray(yw)+",\r"
	else
		if (CategoryPlot)
			obj += "\"x\":" + TxtWaveToJSONArray(xw)+",\r"
		elseif(AutoX) //Use Igor Scaling
			obj += "\"x0\":"+dub2str(dimoffset(yw,0))+",\r"
			obj += "\"dx\":"+dub2str(dimdelta(yw,0))+",\r"
		else
			obj += "\"x\":" + WaveToJSONArray(xw)+",\r"
		endif
		obj += "\"y\":"+ WaveToJSONArray(yw)+",\r"
	endif
	//Get the main color information for this trace.
	string RGB_Array=""		//We'll store data here if a color array is needed
	variable rgbR = round(GetNumFromModifyStr(info,"rgb","(",0)/257)
	variable rgbG = round(GetNumFromModifyStr(info,"rgb","(",1)/257)
	variable rgbB = round(GetNumFromModifyStr(info,"rgb","(",2)/257)		
	string TraceRGB = "\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\""
	variable hbFill = GetNumFromModifyStr(info,"hbFill","",0)
	variable FillA=1
	if (hbFill == 0)
		FillA = 0
	elseif (hbFill == 1)
		fillA = 0  //This is wrong..Actually, this mode should go to the background color.
	elseif(hbFill ==2)
		FillA = 1
	elseif(hbFill==3)
		FillA = 0.75
	elseif(hbFill==4)
		FillA = 0.5
	elseif(hbFill==5)
		FillA = 0.25
	elseif(hbFill>5) //No patterns in Plotly, that I know of.
		FillA = 0.5
	endif
	variable useZcolor = numtype(GetNumFromModifyStr(info,"zColor","",0))	
	if(useZcolor)  //This expression is true if we are using color as f(z), so we create a color array
	 	string ColorInfo =  stringbykey("zColor(x)",info,"=",";") //First check for zColor
	 	if (stringmatch(ColorInfo,"")) 
	 		Colorinfo = stringbykey("RECREATION:zColor(x)",info,"=",";")  //usually, this is the right key.  But may be not always, so keep the if
	 	endif
	 	Colorinfo = colorinfo[1,strlen(colorinfo)-2]  //Strip off the { }
	 	RGB_Array = zColorArray(ColorInfo,PlyMode)  
	endif
	variable lineSize = GetNumFromModifyStr(info,"lSize","",0)
	
//Do things specific to category bar mode.------------------------------------------------------------------------------------------
	if (strsearch(plyMode,"bar",0)>-1) //Bar mode
		
		variable UseBarStroke = GetNumFromModifyStr(info,"useBarStrokeRGB","",0)
		if (UseBarStroke)
			variable BarStrkR = round(GetNumFromModifyStr(info,"barStrokeRGB","(",0)/257)
			variable BarStrkG = round(GetNumFromModifyStr(info,"barStrokeRGB","(",1)/257)
			variable BarStrkB = round(GetNumFromModifyStr(info,"barStrokeRGB","(",2)/257)		
			string BarStrkRGB = "\"rgb("+dub2str(BarStrkR)+","+dub2str(BarStrkG)+","+dub2str(BarStrkB)+")\""
		elseif(useZcolor)
			BarStrkRGB = RGB_Array
		else
			BarStrkRGB = "\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+","+")\""
		endif		
		variable UsePlusRGB = GetNumFromModifyStr(info,"usePlusRGB","",0)
		if (UsePlusRGB)  //These colors have the possiblity of transparency, based on hbFill, set above
			variable BarR = round(GetNumFromModifyStr(info,"plusRGB","(",0)/257)
			variable BarG = round(GetNumFromModifyStr(info,"plusRGB","(",1)/257)
			variable BarB = round(GetNumFromModifyStr(info,"plusRGB","(",2)/257)		
			string BarRGB = "\"rgba("+dub2str(barR)+","+dub2str(BarG)+","+dub2str(BarB)+","+dub2str(FillA)+")\""
		elseif(useZcolor)
			BarRGB = zColorArray(Colorinfo,plymode,transp=FillA)
		else
			BarRGB = "\"rgba("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+","+dub2str(FillA)+")\""
		endif
		obj += "\"marker\":{\r"
		obj += "\"color\":"+BarRGB+",\r"
		obj += "\"line\":{\r"
		obj += "\"color\":"+BarStrkRGB+",\r"
		obj += "\"width\":"+dub2str(lineSize)+"\r"
		obj += "}\r"
		obj += "},\r"
	endif

//Set LINE information-------------------------------------------------------------------------------------------------------------------------------
	if (strsearch(PlyMode,"lines",0)>-1) //the Plotly mode contains a line, so send information about the line
		variable lineStyle = GetNumFromModifyStr(info,"lStyle","",0)
		string PlyDash = AssignLineStyle(LineStyle)
		obj += "\"line\":{\r"
		if (mode==6) // Cityscape
			obj += "\"shape\":\"hv\",\r"
		endif		
		obj += "\"color\":"+TraceRGB+",\r"
		obj += "\"dash\":\""+PlyDash+"\",\r"
		obj += "\"width\":"+dub2str(lineSize)+"\r"
		obj += "},\r"
	endif
//End of LINE information----------------------------------------------------------------------------------------------------------------------------

//Fill information for Fill to Zero--------------------------------------------------------------------------------------------------------------------
	if (mode==7 || mode==6)
			variable PlusrgbR, plusrgbG, plusrgbB
			if (tomode == 1) //Fill to next, but in Plotly it's fill to last so reverst the ordering
				TraceOrderFlag=1
				obj += "\"fill\":\"tonexty\",\r"
			else
				obj += "\"fill\":\"tozeroy\",\r"
			endif
			if (GetNumFromModifyStr(info,"usePlusRGB","",0))
				PlusrgbR = round(GetNumFromModifyStr(info,"plusRGB","(",0)/257)
				PlusrgbG = round(GetNumFromModifyStr(info,"plusRGB","(",1)/257)
				PlusrgbB = round(GetNumFromModifyStr(info,"plusRGB","(",2)/257)
			else
				PlusrgbR = rgbR
				PlusrgbG = rgbG
				PlusrgbB = rgbB	
			endif
			obj += "\"fillcolor\":\"rgba("+dub2str(PlusrgbR)+","+dub2str(PlusrgbG)+","+dub2str(PlusrgbB)+","+dub2str(FillA)+")\",\r"
	endif 
//End of Fill to Zero information-------------------------------------------------------------------------------------------------------------------------

//Markers -----------------------------------------------------------------------------------------------------------------------------------------------------
 	if (strsearch(PlyMode,"markers",0)>-1 || strsearch(PlyMode,"text",0)>-1) //the Plotly mode contains a marker or text marker, so send information about the marker
		MarkerFlag = 1
		string PlyMrkr 
		variable mFill = 0  //This flag will be set to 1 if we need to fill our marker
		variable MrkrSize = GetNumFromModifyStr(info,"msize","",0)
		if (MrkrSize == 0)
			MrkrSize = DefaultMarkerSize
		endif
		variable MrkrrgbR = round(GetNumFromModifyStr(info,"mrkStrokeRGB","(",0)/257) //These are the marker stroke colors reported by Igor
		variable mrkrrgbG = round(GetNumFromModifyStr(info,"mrkStrokeRGB","(",1)/257)
		variable MrkrrgbB = round(GetNumFromModifyStr(info,"mrkStrokeRGB","(",2)/257)
		string MarkerRGB =  "\"rgb("+dub2str(MrkrrgbR)+","+dub2str(MrkrrgbG)+","+dub2str(MrkrrgbB)+")\""
		variable UseMrkrStroke = GetNumFromModifyStr(info,"useMrkStrokeRGB","",0)
		variable opaque =  GetNumFromModifyStr(info,"opaque","",0)	
		string PlyMarkerColor	//We'll set this in the decision tree
		string PlyStrokeColor	//We'll set this in the decision tree
		string SIZE_Array
		variable sizeCode
		variable useZsize = numtype(GetNumFromModifyStr(info,"zmrkSize","",0))
		variable useZmrkNum = numtype(GetNumFromModifyStr(info,"zmrkNum","",0))
		
		if((strsearch(PlyMode,"markers",0)>-1) && !(mode==2))  //We have markers and not dots at points
			if (MrkrSize)  //Adjust the marker size if not set to autosize (0)
				MrkrSize = Mrk2Px(MRkrSize)  //Conver to screen px for Plotly
				If (MrkrSize > LargestMarkerSize)
				 	LargestMarkerSize = MrkrSize
				 endif
				SizeCode = 2
			endif
			variable MrkrThick =  GetNumFromModifyStr(info,"mrkThick","",0)
			obj += "\"marker\":{\r"
			if (useZmrkNum) //We have to make an array of marker types if this if is true,which means we also need an array of marker fill colors
				string MrkNumZwave = ""
				string MRK_Array = ""
				string MRK_RGBArray = ""
				MrkNumZwave = stringbykey("zmrkNum(x)",info,"=",";",1) //We know we have a marker number wave. Extract it by key
				MrkNumZwave = MrkNumZwave[1,strlen(MrkNumZwave)-2] //strip off the { and }
				AssignMarkerNameArray(MrkNumZwave,MRK_Array,MRK_RGBArray,TraceRGB,UseZColor,RGB_Array,opaque) //Make arrays for color and symbol
				obj += "\"symbol\":"+Mrk_Array+",\r"
				obj += "\"color\":"+Mrk_RGBArray+",\r"
			else //Just one marker type
				PlyMrkr = AssignMarkerName( GetNumFromModifyStr(info,"marker","",0),mFill)	//Function to assign marker name
				obj += "\"symbol\":\""+PlyMrkr+"\",\r"		//Marker symbol
				if (MFill == 0 && !opaque)	//this is an non-filled marker type and not opaque
					obj +=  "\"color\":\"rgba(0,0,0,0)\",\r"
				elseif (MFill == 0 && opaque) //This is a non-filled marker type but it's opaqu (white)
					obj += "\"color\":\"rgb(255,255,255)\",\r"
				elseif (UseZColor)  //The marker color is an array
					obj +=  "\"color\":"+RGB_Array + ",\r"
				else	//The marker is filled-type, and set by the main trace color
					obj += "\"color\":"+ TraceRGB + ",\r"
				endif
			endif //End of marker type section
			obj += "\"line\":{\r"  //Marker stroke information  only for markers, not dots or text--------------------------------------------------
			if (UseMrkrStroke)
				obj += "\"color\":"+ MarkerRGB + ",\r"
			elseif (UseZColor) //This is a non-filled marker, and we are using z-color
				obj +=  "\"color\":"+RGB_Array + ",\r"
			else 
				obj += "\"color\":"+ TraceRGB + ",\r"	
			endif				
			obj += "\"width\":"+dub2str(MrkrThick)+"\r},\r"		//----End of stroke
	       elseif (mode==2)  //Igor dots at points
			PlyMrkr = "square"
			MrkrSize = Mrk2Px(GetNumFromModifyStr(info,"lSize","",0)/2)  //For the dots at points command, the size is the same as the line size
			If (MrkrSize > LargestMarkerSize)
			 	LargestMarkerSize = MrkrSize //But we still need 4/3 to go from pts to px
			 endif
			SizeCode = 1
			obj += "\"marker\":{\r"
			obj += "\"symbol\":\""+PlyMrkr+"\",\r"
			if (UseZColor)
				obj +=  "\"color\":"+RGB_Array + ",\r"
			else
				obj += "\"color\":"+ TraceRGB + ",\r" 
			endif
		else //So we are left with text markers
			string txtInfo = stringbykey("textmarker(x)",info,"=",";")  //Read all the information about the text markers
			string txt
			variable infoPntr //This will be a pointer to keep track of positions in the string as we parse it
			MrkrSize = Txt2Px(MrkrSize)  //Text size is 3*marker size
			If (MrkrSize > LargestMarkerSize)
			 	LargestMarkerSize = MrkrSize
			 endif			
			SizeCode = 3
			obj += "\"text\":" 
			infoPntr = strsearch(txtinfo,",",0) //Set a pointer to the place where we find the first comma, after the text.
			if (char2num(txtinfo[1]) == 34)  //The graph text is a string, not a wave, CHAR(34) is a quote "
				txt = txtinfo[2,infoPntr-2] //Igor allows strings with up to 3 chars for the text marker. This line pulls out the marker
				make/T/O/N=(trlen) txtWave = txt
				obj += txtWavetoJSONArray(txtWave)
			else  //The text is specified by a wave.
				txt = txtinfo[1,infoPntr-1] //There are no quotes around the wave name, so move only 1 space back from the comma
				if (wavetype($txt)) //wavetype is 0 for non-numeric waves, so TRUE means we have a numeric wave
					duplicate/o $txt LocalTxt
					make/T/O/N=(trlen) txtWave = dub2str(LocalTxt)
					obj += txtWaveToJSONArray(txtWave)
				else
					obj += txtWaveToJSONArray($txt)
				endif
			endif
			obj += ",\r"
			txtinfo = txtinfo[infopntr+1,inf]
			infopntr = strsearch(txtinfo,",",0)
			string txtFont = txtinfo[0,infopntr-1]
			string txtrgbR, txtrgbG, txtrgbB
	
			obj += "\"textfont\":{\r"
			obj += "\"family\":"+txtFont+",\r"
			if (UseMrkrStroke) //If this parameter is 1, the text is different than the main trace color
				obj += "\"color\":"+ MarkerRGB + ",\r"
			elseif (useZcolor)
				obj +=  "\"color\":"+RGB_Array + ",\r"
			else 
				obj += "\"color\":"+ TraceRGB + ",\r"	
			endif			
		endif  //-----------End of Text Markers section
		
		if (useZsize && !(SizeCode == 1))
		 	string SizeInfo =  stringbykey("zmrkSize(x)",info,"=",";") //First check for zColor
		 	Sizeinfo = Sizeinfo[1,strlen(Sizeinfo)-2]  //Strip off the { }					
		 	Size_Array = zSizeArray(SizeInfo,SizeCode)  
		 	obj += "\"size\":" + Size_Array +",\r"
		elseif(mrkrSize==0)  //Check whether the marker size is 0, which means autosize
			obj += "\"size\":"+dub2str(Txt2Px(DefaultTextSize))+",\r"	
		else
			obj += "\"size\":"+dub2str(Txt2Px(2*mrkrSize))+",\r"	
		endif
		variable mskip = GetNumFromModifyStr(info,"mskip","",0)  
		if (mskip>0 && strsearch(PlyMode,"lines",0)>-1)		//We only skip markers is there is also a line being drawn.
			variable maxMarkers =  trLen / (mskip+1) 
			obj += "\"maxdisplayed\":"+dub2str(maxMarkers)+",\r"
		endif
		obj = obj[0,strlen(obj)-3]  //Remove the damn comma.
		obj += "\r},\r"
	endif
//End of Markers-----------------------------------------------------------------------------------------------------------------------------------------

//Set MODE information---------------------------------------------------------------------------------------------------------------------------------
	if (GetNumFromModifyStr(info,"gaps","",0)==0)
		obj += "\"connectgaps\":true,\r"
	endif
	
	obj += "\"name\":\""+PlyName+"\",\r"
	if (mode==5)
		obj += "\"type\":\"bar\",\r"
	else
		obj += "\"type\":\"scatter\",\r"
	endif
	obj += "\"mode\":\""+PlyMode+"\",\r"  
//End MODE-------------------------------------------------------------------------------------------------------------------------------------------

//Set Error bar information---------------------------------------------------------------------------------------------------------------------------
	string EBinfo = stringbykey("ERRORBARS",info,":",";",1)  //Read EB info
	if (strlen(EBinfo)>0)  //If this is true, it means we need to do some error bars
		EBinfo = EBinfo[9,strlen(EBinfo)]  //Stip out the word Errorbars
		variable EBcapThk = str2num(StringbyKey("T",EBInfo,"=","/") )
		variable EBlineThk = str2num(StringbyKey("L",EBInfo,"=","/") )		
		variable EBxW = str2num(StringbyKey("X",EBInfo,"=","/") )		
		variable EByW = str2num(StringbyKey("Y",EBInfo,"=","/") )

		variable sp1=strsearch(EBinfo," ",0) //We find the first space. After the first space is the trace name
		variable cma1=strsearch(EBinfo,",",0) //We find the first comma
		variable sp2=strsearch(EBinfo," ",cma1,1)  //We find the last space before the comma. After this space is the mode of error bars
		
		variable PosEndX=0  //This will tell us where the info for the first error bar ends, which we need to know if we need to worry about a second error bar
		string EBmode = EBinfo[sp2+1,cma1-1]
	      string ErSpec1 = EBinfo[cma1+1] //We only need the first character after the string to figure out what the error specification is. :pct,sqrt,const,wave
		if (stringmatch(ErSpec1,"w") )	//The first error spec is a wave type
			variable pL = strsearch(EBinfo,"(",cma1) //find left (
			variable Wcma = strsearch(EbInfo,",",pL) //find the , between the wave names
			variable pR = strsearch(EBinfo,")",Wcma) //find the )
			string pw1 = EBinfo[pL+1,Wcma-1]  //Wave for plus error bar 1
			string mw1 = EBinfo[Wcma+1,pR-1] //wave for minus error bar 1
			PosEndX=pR+1
		else
			variable eq = strsearch(EBinfo,"=",cma1)  //Find the = 
			variable cma2 =  strsearch(EBinfo,",",cma1+1) 		//find the ,
			PosEndX=cma2
			if (cma2 <0)
				cma2 = strlen(EBinfo )+1
			endif
			string val1 = ebinfo[eq+1,cma2-1]
		endif
		if (stringmatch(EBmode,"X") || stringmatch(EBmode,"XY") || stringmatch(EBmode,"BOX") )
			obj += "\"error_x\":{\r"
			obj += "\"visible\":true,\r"
//			if (UseZColor)
//				obj +=  "\"color\":"+RGB_Array + ",\r"	//RGB color arrays do not seem to work with Plotly now.
//			else 
				obj += "\"color\":"+ TraceRGB + ",\r"	
//			endif			
//			if (!numtype(EBcapThk)) //Set the cap thickness.  But Plotly doesn't allow it
			if (!numtype(EBlineThk)) //Set the line thickness
					obj += "\"thickness\":"+dub2str(EBlineThk)+",\r"
				else 	
					obj += "\"thickness\":1,\r"
				endif
				if(!numtype(EByW)) //Set the y-cap width 
					obj += "\"width\":"+dub2str(EByW)+",\r"
					if (LargestMarkerSize < EByW)
						LargestMarkerSize = EByW
					endif
				else
					obj += "\"width\":"+dub2str(DefaultMarkerSize)+",\r"
					if (LargestMarkerSize < DefaultMarkerSize)
						LargestMarkerSize = DefaultMarkerSize
					endif
			endif
			if (stringmatch(ErSpec1,"w") ) //Wave type errors 
				obj += "\"type\":\"data\",\r"
				if (strlen(pw1)>0)
				 	obj += "\"array\":"+wavetoJSONarray($pw1)+",\r"
				 else
				 	make/O/FREE/N=(TrLen) NullEB = 0
				 	obj += "\"array\":"+wavetoJSONarray(NullEB)+",\r"
				 endif
				if (stringmatch(pw1,mw1))
					obj += "\"symmetric\":true,\r"
				else
					if (strlen(mw1)>0)
					 	obj += "\"arrayminus\":"+wavetoJSONarray($mw1)+",\r"
					 else
					 	make/O/FREE/N=(TrLen) NullEB = 0
					 	obj += "\"array\":"+wavetoJSONarray(NullEB)+",\r"
					 endif
				endif
			elseif (stringmatch(ErSpec1,"p")) //percent type errors
				obj += "\"type\":\"percent\",\r"
				obj += "\"value\":"+val1+",\r"
				obj += "\"symmetric\":true,\r"
			elseif(stringmatch(ErSpec1,"s")) //sqrt type errors
				obj += "\"type\":\"sqrt\",\r"
				obj += "\"symmetric\":true,\r"
			else //constant type errors
				obj += "\"type\":\"constant\",\r"
				obj += "\"value\":"+val1+",\r"
				obj += "\"symmetric\":true,\r"
			endif	
			obj = obj[0,strlen(obj)-3]  //Remove the damn comma.
			obj += "\r},\r"	// End of the X-section when there area x AND y error bars	-----------------------------------------------------------------------------------
			EBinfo = EBinfo[PosEndx+1,strlen(EBinfo)]  //Strip off the EB info we've already extracted so we can extract more
			if (stringmatch(EBMode,"XY") || stringmatch(EBmode,"BOX") ) ///These two modes have a second error bar to deal with which requires more string-scanning.  
				//BOX isn't supported in  Plotly, so we just to regular error bars as a kludge
				obj += "\"error_y\":{\r"
				obj += "\"visible\":true,\r"
	//			if (UseZColor)
	//				obj +=  "\"color\":"+RGB_Array + ",\r"	//RGB color arrays do not seem to work with Plotly now.
	//			else 
					obj += "\"color\":"+ TraceRGB + ",\r"	
//				endif			
	//			if (!numtype(EBcapThk)) //Set the cap thickness.  But Plotly doesn't allow it
				if (!numtype(EBlineThk)) //Set the line thickness
					obj += "\"thickness\":"+dub2str(EBlineThk)+",\r"
				else 	
					obj += "\"thickness\":1,\r"
				endif
				if(!numtype(EByW)) //Set the y-cap width 
					obj += "\"width\":"+dub2str(EByW)+",\r"
					if (LargestMarkerSize < EByW)
						LargestMarkerSize = EByW
					endif
				else
					obj += "\"width\":"+dub2str(DefaultMarkerSize)+",\r"
					if (LargestMarkerSize < DefaultMarkerSize)
						LargestMarkerSize = DefaultMarkerSize
					endif
			endif
				//Now we have to parse through the EB info again				
			      string ErSpec2 = EBinfo[0] //We only need the first character after the string to figure out what the error specification is. :pct,sqrt,const,wave
				if (stringmatch(ErSpec2,"w") )	//The first error spec is a wave type
					pL = strsearch(EBinfo,"(",0) //find left (
					Wcma = strsearch(EbInfo,",",pL) //find the , between the wave names
					pR = strsearch(EBinfo,")",Wcma) //find the )
					pw1 = EBinfo[pL+1,Wcma-1]  //Wave for plus error bar 1
					mw1 = EBinfo[Wcma+1,pR-1] //wave for minus error bar 1
				else
					eq = strsearch(EBinfo,"=",0)  //Find the = 
					cma2 =  strsearch(EBinfo,",",0) 		//find the ,
					if (cma2 <0)
						cma2 = strlen(EBinfo )+1
					endif
					val1 = ebinfo[eq+1,cma2-1]
				endif

				if (stringmatch(ErSpec2,"w") ) //Wave type errors 
					obj += "\"type\":\"data\",\r"
					if (strlen(pw1)>0)
					 	obj += "\"array\":"+wavetoJSONarray($pw1)+",\r"
					 else
					 	make/O/FREE/N=(TrLen) NullEB = 0
					 	obj += "\"array\":"+wavetoJSONarray(NullEB)+",\r"
					 endif
					if (stringmatch(pw1,mw1))
						obj += "\"symmetric\":true,\r"
					else
						if (strlen(mw1)>0)
						 	obj += "\"arrayminus\":"+wavetoJSONarray($mw1)+",\r"
						 else
						 	make/O/FREE/N=(TrLen) NullEB = 0
						 	obj += "\"array\":"+wavetoJSONarray(NullEB)+",\r"
						 endif
					endif
				elseif (stringmatch(ErSpec2,"p")) //percent type errors
					obj += "\"type\":\"percent\",\r"
					obj += "\"value\":"+val1+",\r"
					obj += "\"symmetric\":true,\r"
				elseif(stringmatch(ErSpec2,"s")) //sqrt type errors
					obj += "\"type\":\"sqrt\",\r"
					obj += "\"symmetric\":true,\r"
				else //constant type errors
						obj += "\"type\":\"constant\",\r"
					obj += "\"value\":"+val1+",\r"
					obj += "\"symmetric\":true,\r"
				endif	
				obj = obj[0,strlen(obj)-3]  //Remove the damn comma.
				obj += "\r},\r"		
			endif	///End of handling x+y error bars------------------------------------------------------------------------------------------------
					
		else  //--End of x-error bar section.  If we are here, it means we have ONLY y-error bars
			obj += "\"error_y\":{\r"
			obj += "\"visible\":true,\r"
//			if (UseZColor)
//				obj +=  "\"color\":"+RGB_Array + ",\r"	//RGB color arrays do not seem to work with Plotly now.
//			else 
				obj += "\"color\":"+ TraceRGB + ",\r"	
//			endif			
//			if (!numtype(EBcapThk)) //Set the cap thickness.  But Plotly doesn't allow it
			if (!numtype(EBlineThk)) //Set the line thickness
					obj += "\"thickness\":"+dub2str(EBlineThk)+",\r"
				else 	
					obj += "\"thickness\":1,\r"
				endif
				if(!numtype(EByW)) //Set the y-cap width 
					obj += "\"width\":"+dub2str(EByW)+",\r"
					if (LargestMarkerSize < EByW)
						LargestMarkerSize = EByW
					endif
				else
					obj += "\"width\":"+dub2str(DefaultMarkerSize)+",\r"
					if (LargestMarkerSize < DefaultMarkerSize)
						LargestMarkerSize = DefaultMarkerSize
					endif
			endif
			if (stringmatch(ErSpec1,"w") ) //Wave type errors 
				obj += "\"type\":\"data\",\r"
				if (strlen(pw1)>0)
				 	obj += "\"array\":"+wavetoJSONarray($pw1)+",\r"
				 else
				 	make/O/FREE/N=(TrLen) NullEB = 0
				 	obj += "\"array\":"+wavetoJSONarray(NullEB)+",\r"
				 endif
				if (stringmatch(pw1,mw1))
					obj += "\"symmetric\":true,\r"
				else
					if (strlen(mw1)>0)
					 	obj += "\"arrayminus\":"+wavetoJSONarray($mw1)+",\r"
					 else
					 	make/O/FREE/N=(TrLen) NullEB = 0
					 	obj += "\"array\":"+wavetoJSONarray(NullEB)+",\r"
					 endif
				endif
			elseif (stringmatch(ErSpec1,"p")) //percent type errors
				obj += "\"type\":\"percent\",\r"
				obj += "\"value\":"+val1+",\r"
				obj += "\"symmetric\":true,\r"
			elseif(stringmatch(ErSpec1,"s")) //sqrt type errors
				obj += "\"type\":\"sqrt\",\r"
				obj += "\"symmetric\":true,\r"
			else //constant type errors
				obj += "\"type\":\"constant\",\r"
				obj += "\"value\":"+val1+",\r"
				obj += "\"symmetric\":true,\r"
			endif	
			obj = obj[0,strlen(obj)-3]  //Remove the damn comma.
			obj += "\r},\r"		
		endif //End of ONLY y-error bar section
	endif
//End error bars---------------------------------------------------------------------------------------------------------------------------------------------
	if(GetNumFromModifyStr(info,"hideTrace","",0))
		obj += "\"visible\":false,\r"
	endif
	obj = obj[0,strlen(obj)-3]  //Remove the damn comma.
	obj += "\r}"
	return obj
end

static Function ReadAchorDomain(graph,anchorAx,anchorDlo,anchorDhi) //Returns the domain of the anchor axis as pointers
	string graph, anchorAx
	variable &anchorDlo,&anchorDhi
	string info = AxisInfo(graph, anchorAx)
	anchorDLo = GetNumFromModifyStr(info,"axisEnab","{",0)
	anchorDHi = GetNumFromModifyStr(info,"axisEnab","{",1)
end
	
static Function/T createAxisObj(axisName,PlyAxisName,graph,Orient,AxisNum)
	string axisName,PlyAxisName,graph,orient
	Variable AxisNum
	string obj = "\""+plyAxisName+"\" : {\r"
	string info = AxisInfo(graph, axisName)
//	IgorNB(info+"\r\r")
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	NVAR SizeMode = root:Packages:Plotly:SizeMode
//	NVAR DefaultTextSize = root:Packages:Plotly:DefautTextSize
	NVAR DefaultTickLength = root:Packages:Plotly:DefaultTickLength
	NVAR DefaultMarkerSize = root:Packages:Plotly:DefaultMarkerSize //In Igor size, not points		
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize //In Igor size, not points			
	NVAR Standoff = root:Packages:Plotly:Standoff
	NVAR HL =root:Packages:Plotly:HL
	NVAR HR =root:Packages:Plotly:HR
	NVAR VT =root:Packages:Plotly:VT
	NVAR VB =root:Packages:Plotly:VB		
	NVAR catGap = root:Packages:Plotly:catGap
	NVAR barGap = root:Packages:Plotly:barGap
	SVAR BarToMode = root:packages:Plotly:BarToMode
	NVAR catCount = root:packages:Plotly:CatCount	
	variable rgbR 
	variable rgbG 
	variable rgbB 

	string XAxis = stringbykey("XAXIS",info,":",";",1)  //Get the name of the x-axis
	string YAxis = stringbykey("YAXIS",info,":",";",1) //Get the name of the y-axis
//	variable xaxNum = whichlistitem(XAxis,XaxisList)
//	variable yaxNum = whichlistitem(YAxis,YaxisList)

	string AxisFlags = stringbykey("AXFLAG",info,":",";",1)
	string Lnam = stringByKey("L",AxisFlags,"=","/",1)
	string Tnam = stringByKey("T",AxisFlags,"=","/",1)
	string Rnam = stringByKey("R",AxisFlags,"=","/",1)
	string Bnam = stringByKey("B",AxisFlags,"=","/",1)
	variable FreeLo,FreeHi, pxSize, FreeNumPerPx, FreeFrac
	variable domainLow = GetNumFromModifyStr(info,"axisEnab","{",0)
	variable domainHigh = GetNumFromModifyStr(info,"axisEnab","{",1)
	obj += "\"domain\" : ["+dub2str(domainLow)+","+dub2str(domainHigh)+"],\r"  //Set the axis domain 


	variable AnchorData
	string AnchorAx
	variable FreeIndex = strsearch(info,"freePos",0)  //Read to see if there is a free axis here
	variable cma,curly
	variable RorT
	If (stringmatch(orient,"H"))  //Horizontal axis...figure out top or bottom
		if (AxisNum>0)		//We need to do overlaying if the axis is >1
			//obj+="\"overlaying\":\"x"+dub2str(AxisNum)+"\",\r"
//			obj+="\"overlaying\":\"x1\",\r"
		endif
		if (stringmatch(axisname,"bottom") || strlen(Bnam)>0)
			obj += "\"side\":\"bottom\",\r"
			RorT = 0 //Set a flag if this is a right or top axis
		else
			obj += "\"side\":\"top\",\r"
			RorT = 1
		endif
		//Free axis calculations for Horizontal axes-----------------------------------------------------------------------------
		if (FreeIndex>-1) //this is a free axis if true
			if (stringmatch(info[Freeindex + 11],"{")) 	//We have to read a number and an axis name
				cma = strsearch(info,",",freeindex+11)
				curly = strsearch(info,"}",cma)
				AnchorData = str2num(info[FreeIndex+12,cma-1])
				AnchorAx = info[cma+1,curly-1]
				if (stringmatch(anchorAx,"kwFraction") ) //This is a fraction of the graph area...Plotly native!
					obj+="\"anchor\":\"free\",\r"
					obj+="\"position\":"+num2str(AnchorData)+",\r"
				else // The free axis is specified against a vertical axis in Igor, so now we need to calculate :(	
					getwindow $graph, psizeDC //Look up the plot px dimensions
					pxSize = V_bottom - V_top  //The pixel size of the plot area
					Getaxis/W=$Graph/Q $anchorAx  // get the igor range of the axis we're anchoring to
					FreeNumPerPX=  abs(V_min-V_max)/pxSize	
					FreeLo = V_min // - (LargestMarkerSize*2.25)*FreeNumperPx   //If changed, also need to change the axis scaling section.  Complicated because of standoff
					FreeHi = V_max // + (LargestMarkerSize*2.25)*FreeNumPerPx
					variable anchorDlo=0  //Variables to store the domain range of the crossing axis
					variable anchorDhi=1
					ReadAchorDomain(graph,anchorAx,anchorDlo,anchorDhi) //Returns the domain of the anchor axis as pointers
					FreeFrac = anchorDlo + (anchorDhi-anchorDlo)*(AnchorData-FreeLo)/(FreeHi-FreeLo)
					obj+="\"anchor\":\"free\",\r"
					obj+="\"position\":"+dub2str( FreeFrac )+",\r"
				endif
			else //'Just" have to read a pixel number
				getwindow $graph, psize //Look up the plot pt dimensions
				pxSize = V_bottom - V_top  //The POINT size of the plot area
				cma = strsearch(info,";",freeIndex+11) //Actually a semicolon...
				AnchorData = Str2num(info[FreeIndex+11,cma-1])  //Read the position of the axis supposedly in points from the bottom axis
				FreeFrac = -(AnchorData/PxSize)
				obj+="\"anchor\":\"free\",\r"
				if (RorT) //Have to go from the other margin if Right or Top
					obj+="\"position\":"+dub2str( 1-FreeFrac )+",\r"
				else
					obj+="\"position\":"+dub2str( FreeFrac )+",\r"
				endif
			endif  
		endif  //Not a free axis, so do nothing
	else  //Vertical  axis
		if (AxisNum>0)		//We need to do overlaying if the axis is >1
//			obj+="\"overlaying\":\"y1\",\r"
		endif
		if (stringmatch(axisname,"left") || strlen(Lnam)>0)
			obj += "\"side\":\"left\",\r"
			RorT = 0
		else
			obj += "\"side\":\"right\",\r"
			RorT = 1
		endif
		//Freee Axis for verticle
		if (FreeIndex>-1) //this is a free axis if true
			if (stringmatch(info[Freeindex + 11],"{")) 	//We have to read a number and an axis name
				cma = strsearch(info,",",freeindex+11)
				curly = strsearch(info,"}",cma)
				AnchorData = str2num(info[FreeIndex+12,cma-1])
				AnchorAx = info[cma+1,curly-1]
				if (stringmatch(anchorAx,"kwFraction") ) //This is a fraction of the graph area...Plotly native!
					obj+="\"anchor\":\"free\",\r"
					obj+="\"position\":"+num2str(AnchorData)+",\r"
				else // The free axis is specified against a vertical axis in Igor, so now we need to calculate :(
					getwindow $graph, psizeDC //Look up the plot px dimensions
					pxSize = V_right - V_left  //The pixel size of the plot area
					Getaxis/W=$Graph/Q $anchorAx  // get the igor range of the axis we're anchoring to
					FreeNumPerPX=  abs(V_min-V_max)/pxSize
					FreeLo = V_min // - (LargestMarkerSize*2.25)*FreeNumperPx   //If changed, also need to change the axis scaling section
					FreeHi = V_max // + (LargestMarkerSize*2.25)*FreeNumPerPx
					ReadAchorDomain(graph,anchorAx,anchorDlo,anchorDhi) //Returns the domain of the anchor axis as pointers
					FreeFrac = anchorDlo + (anchorDhi-anchorDlo)*(AnchorData-FreeLo)/(FreeHi-FreeLo)
					obj+="\"anchor\":\"free\",\r"
					obj+="\"position\":"+dub2str( FreeFrac )+",\r"
				endif
			else //'Just" have to read a pixel number
				getwindow $graph, psize //Look up the plot pt dimensions
				pxSize = V_right - V_left  //The POINT size of the plot area
				cma = strsearch(info,";",freeIndex+11) //Actually a semicolon...
				AnchorData = Str2num(info[FreeIndex+11,cma-1])  //Read the position of the axis supposedly in points from the bottom axis
				FreeFrac = -(AnchorData/PxSize)
				obj+="\"anchor\":\"free\",\r"
				if (RorT)  //Have to go from the other margin if Right or Top
					obj+="\"position\":"+dub2str( 1-FreeFrac )+",\r"
				else
					obj+="\"position\":"+dub2str( FreeFrac )+",\r"
				endif
			endif  
		endif  //Not a free axis, so do nothing
	endif

	string DefaultFnt = GetDefaultFont(graph)
	variable DefaultTextSize_pt = GetDefaultFontSize(graph,"") //This number is returned in POINTS
	//Axis Label/Title----------------------------------------------------------------------------------------------------------------------------------------
	string LblTxt = AxisLabelText(graph, axisName, SuppressEscaping=1)
	String altFont //= ExtractFont(LblTxt) //Try to read a font escape code, and extract it if it exists
	variable altFontSize,OZ // = ExtractFontSize(LblTxt) //Try to read a font size escpe code, and extract if it exists
	LblTxt = ProcessText(LblTxt,altFont,altFontsize,OZ)
	obj += "\"title\":\""+LblTxt+"\",\r"
//	if (!stringmatch(altFont,"default") || altFontSize > 0) //A font property is not default
	obj += "\"titlefont\":{\r"
	if (!stringmatch(altFont,"default"))
		obj += "\"family\":\""+altFont+"\",\r"
	endif
	if (AltFontSize>0)
		obj += "\"size\":"+num2str(txt2px(AltFontSize))+",\r"
	endif
	rgbR = round(GetNumFromModifyStr(info,"alblRGB","(",0)/257)
	rgbG = round(GetNumFromModifyStr(info,"alblRGB","(",1)/257)
	rgbB = round(GetNumFromModifyStr(info,"alblRGB","(",2)/257)		
	obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\"\r"
	obj += "},\r"
	
	//Axis visuals -----------------------------------------------------------------------------------------------------------
	rgbR = round(GetNumFromModifyStr(info,"axRGB","(",0)/257)
	rgbG = round(GetNumFromModifyStr(info,"axRGB","(",1)/257)
	rgbB = round(GetNumFromModifyStr(info,"axRGB","(",2)/257)	
	obj += "\"linecolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	variable axThick = GetNumFromModifyStr(info,"axThick","",0)
	if (axThick > 0)
		obj += "\"showline\" : true,\r"
		obj += "\"linewidth\" :" +dub2str(ceil(axThick)) +",\r"
	else
		obj += "\"showline\" : false,\r"
	endif
	variable zero =  GetNumFromModifyStr(info,"zero","",0)
	variable zeroThick = GetNumFromModifyStr(info,"zeroThick","",0)
	if (zero) //Show the zero line
		obj += "\"zeroline\" : true,\r"
		obj += "\"zerolinecolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r" //Same color as the axis, I'm afraid
		if (zeroThick) 
			obj += "\"zerolinewidth\" : "+dub2str(ZeroThick)+",\r"
		else
			obj += "\"zerolinewidth\" : "+dub2str(axThick)+",\r"
		endif
	else
		obj += "\"zeroline\" : false,\r"
	endif
	//Mirror : "true", "ticks", "false", "all", "all+ticks"
	variable mirror =  GetNumFromModifyStr(info,"mirror","",0)
	if (mirror==1)
		obj += "\"mirror\" : \"ticks\",\r"
	elseif (mirror == 2)
		obj += "\"mirror\" : true,\r"
	elseif (mirror == 3)
		obj += "\"mirror\" : \"all+ticks\",\r"
	else
		obj += "\"mirror\" : false,\r"
	endif
	variable grid = GetNumFromModifyStr(info,"grid","",0)
	if (grid)
		rgbR = round(GetNumFromModifyStr(info,"gridRGB","(",0)/257)
		rgbG = round(GetNumFromModifyStr(info,"gridRGB","(",1)/257)
		rgbB = round(GetNumFromModifyStr(info,"gridRGB","(",2)/257)	
		obj += "\"showgrid\": true,\r"
		obj += "\"gridcolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	else
		obj += "\"showgrid\": false,\r"
	endif

	
	//Tick Visuals-------------------------------------------------------------------------------------------------------------
	variable btThick = GetNumFromModifyStr(info,"btThick","",0)
	if (btThick == 0 )
		btThick = axThick
	endif
	obj += "\"tickwidth\":"+num2str(btThick)+",\r"
	
	obj += "\"tickcolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"  //Same as axis color
	obj += "\"tickfont\":{\r"
//	obj += "\"family\":\""+defaultFnt+"\",\r"		//Igor always uses the graph default size and font for lablels
//	obj += "\"size\":"+num2str(txt2px(DefaultTextSize_pt))+",\r"
	rgbR = round(GetNumFromModifyStr(info,"tlblRGB","(",0)/257)
	rgbG = round(GetNumFromModifyStr(info,"tlblRGB","(",1)/257)
	rgbB = round(GetNumFromModifyStr(info,"tlblRGB","(",2)/257)	
	obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\"\r"
	obj += "},\r"
	
	variable btLen = GetNumFromModifyStr(info,"btLen","",0)
	if (btLen==0)
		btLen = DefaultTickLength
	endif
	obj += "\"ticklen\":"+num2str(btLen)+",\r"	
	variable tickType = GetNumFromModifyStr(info,"tick","",0)
	if (tickType==0)
		obj += "\"ticks\" : \"outside\",\r"
	elseif (tickType==1) //Crossing axes...not sure what to do, not supported by Plotly
		obj += "\"ticks\" : \"crossing\",\r"
		print "WARNING: Crossing ticks not supported by Plotly"
	elseif (tickType==2)
		obj += "\"ticks\" : \"inside\",\r"
	else
		obj += "\"ticks\" : \"\",\r"
	endif
	variable noLabel = GetNumFromModifyStr(info,"noLabel","",0)  //Decide whether to show tick labels
	if (noLabel == 1 || noLabel == 2) 
		obj += "\"showticklabels\":false,\r"
	endif
	//Axis Range and axis side assignment  This is complicated because of the need to do standoff.
	Getaxis/W=$Graph/Q $axisName  // get the igor range
	variable IgLo = V_min
	Variable IgHi = V_max
	variable PlyLo
	variable PlyHi 
	getwindow $graph, psizeDC //Look up the plot px dimensions
	variable pheight = V_bottom - V_top
	variable pwidth = V_right - V_left
	variable p_bottom = V_bottom
	variable p_top = v_top
	variable p_left = v_left
	variable p_right = v_right
	variable numPerpx

	variable IsLog= GetNumFromModifyStr(info,"log","",0)
	if (stringmatch(orient,"H") && !isLog) //can't do simple standoff calc on log axis
		NumPerPX=  abs(IgLo-IgHi)/pwidth
		PlyLo = IgLo - (LargestMarkerSize*2.25)*NumPerPx  //If you change this, also need to take care of Free axis section.  Changed from /1.25 to *1.25 because of apparent marker size change
		PlyHi = IgHi + (LargestMarkerSize*2.25)*NumPerPx
	elseif(stringmatch(orient,"H"))
		NumPerPx = (abs(log(IgLo))-abs(log(IgHi)))/pwidth
		PlyLo = log(IgLo) - (LargestMarkerSize*2.25)*NumPerPx
		PlyHi = log(IgHi) + (LargestMarkerSize*2.25)*NumPerPx
	endif
	If (stringmatch(orient,"V")&& !isLog) //Can't do simple standoff calc on log axis
		NumPerPX=  abs(IgLo-IgHi)/pheight
		PlyLo = IgLo - (LargestMarkerSize*2.25)*NumPerPx
		PlyHi = IgHi + (LargestMarkerSize*2.25)*NumPerPx
	elseif(stringmatch(orient,"V"))
		NumPerPx = (abs(log(IgLo))-abs(log(IgHi)))/pheight
		PlyLo = log(IgLo) - (LargestMarkerSize*2.25)*NumPerPx
		PlyHi = log(IgHi) + (LargestMarkerSize*2.25)*NumPerPx
	endif

	variable IsCat= NumberByKey("ISCAT",info,":",";",0)
	If (IsCat)
		obj += "\"type\": \"catgory\",\r"
		catGap = GetNumFromModifyStr(info,"catGap","",0)  //Save these in the global list for use in the global section of KWARGS
		barGap = GetNumFromModifyStr(info,"barGap","",0)
		if (PlyLo > -0.5)  //We need to adjust for plotly category plots, they go to -.5.  But we allow for intentionally MORE negative ranges...
			PlyLo = -0.5
		endif
		if(PlyHi == CatCount)
			PlyHi = catCount - 0.5
		endif
	elseif (IsLog)
		obj += "\"type\": \"log\",\r"
	else
		obj += "\"type\": \"linear\",\r"		
	endif
	obj += "\"exponentformat\":\"power\",\r"
	obj += "\"range\": ["+dub2str(PlyLo)+","+dub2str(PlyHi)+"],\r"
	
	obj = obj[0,strlen(obj)-3]
	obj += "\r},\r"
	return (Obj)
end


static function/T AnchorText(A)
	string A
	string obj = ""
	if (strsearch(A,"L",0)>-1)
		obj += "\"xanchor\":\"left\",\r"
	elseif(strsearch(A,"M",0)>-1)
		obj += "\"xanchor\":\"center\",\r"
	elseif(strsearch(A,"R",0)>-1)
		obj += "\"xanchor\":\"right\",\r"
	endif
	if (strsearch(A,"T",0)>-1)
		obj += "\"yanchor\":\"top\",\r"
	elseif(strsearch(A,"C",0)>-1)
		obj += "\"yanchor\":\"middle\",\r"
	elseif(strsearch(A,"B",0)>-1)
		obj += "\"yanchor\":\"bottom\",\r"
	endif
	return obj
end

Function ReadWaveAxes(graph,yw,PlyYaxName,PlyXaxName)
	string graph, yw, &PlyYaxName, &PlyXaxName
	string info = traceinfo(graph,yw,0)
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	string xax = stringbyKey("XAXIS",info,":",";",1)
	string yax = stringbyKey("YAXIS",info,":",";",1)
	string Hax, Vax
	variable foundH = 0
	variable foundV = 0
	variable i=0
	do
		Hax = stringfromList(i,Haxislist,";")
		Vax = stringfromList(i,Vaxislist,";")
		if (stringmatch(Hax,"") && stringmatch(Vax,""))
			break
		endif
		if (stringmatch(xax,Hax) || stringmatch(yax,Hax))
			PlyXaxName = "x"+num2str(i+1)
			foundH = 1
		endif
		if (stringmatch(xax,Vax) || stringmatch(yax,Vax))
			PlyYaxName = "y"+num2str(i+1)
			foundV = 1
		endif
		i += 1
	while ((FoundH==0) || (FoundV==0))
end

static function/T CreateAnnotationObj(Name,graph)
	string name,graph
	string info = annotationinfo(graph,name,1)
//	IgorNB(info+"\r\r")
	string Type =  stringbykey("TYPE",info,":",";",1)
	string obj = ""
	string Flags = stringbyKey("FLAGS",info,":",";",1)
	string anchorCode,BackCode,DFlag,TxtColor,exterior,text
	variable absX,absY,fracx,fracy,Xpos,Ypos,xOff,yOff,Rotation
	getwindow $graph, gsize //Look up the size of the graph window, in points
	variable g_left = V_left
	variable g_right = V_right
	variable g_top = V_top
	variable g_bottom = V_bottom
	getwindow $graph, psize //look up the plot size in points
	variable p_left = V_left
	variable p_right = V_right
	variable p_top = V_top
	variable p_bottom = V_bottom
	variable rgbR,rgbG,rgbB,rgbA,Frame
	NVAR DefaultMarkerSize = root:Packages:Plotly:DefaultMarkerSize //In Igor size, not points	
	
	if (stringmatch(type,"Legend") || stringmatch(type,"ColorScale") ) //Get the legend object started.
		return ""
	elseif (stringmatch(type,"Tag" )) //Do the tag-specific things first, then to generic annotation things later-----------------------------------------------
		//variable line = str2num(stringbykey("L",flags,"=","/",1) )  IGOR BUG! Line not returned in annotationInfo!
		variable line = PLYParseTagForLine(graph,name)
		obj += "{\r"
		
		xOff = str2num(stringbykey("X",flags,"=","/",1))/100
		yOff = str2num(stringbykey("Y",flags,"=","/",1))/100
		if (line == 0 ||  (xOff==0 && yOff==0))
			obj += "\"showarrow\":false,\r"
		elseif (line == 1)
			obj += "\"showarrow\":true,\r"
			obj += "\"arrowhead\":0,\r"
		else
			obj += "\"showarrow\":true,\r"
			obj += "\"arrowhead\":3,\r"
		endif
		obj += "\"arrowwidth\":1,\r"
		obj += "\"arrowsize\":"+dub2str(ceil(defaultmarkersize/5))+",\r" ///This arrow size gives a good guess to the way Igor autoscales the arrow.
		
		variable ax = (xOff * (p_right-p_left))*screenresolution/72
		variable ay = (yOff * (p_top-p_bottom))*screenresolution/72
		variable attachx = str2num(stringbykey("ATTACHX",info,":",";",1))
		string yw = stringbykey("YWAVE",info,":",";",1)
		string ywf = stringbykey("YWAVEDF",info,";",";",1)
		string xw = stringbykey("XWAVE",info,":",";",1)
		string xwf = stringbykey("XWAVEDF",info,";",";",1)
		wave ywave = tracenametowaveref(graph,yw)
		ypos = ywave(attachx)		
		if (!stringmatch(xw,"") )
			wave xwave = xwavereffromtrace(graph,yw)
			variable pnt = x2pnt(ywave,attachx)
			xpos = xwave[pnt]
		else
			xpos = attachx
		endif
		string PlyXaxName=""
		string PlyYaxName=""
		ReadWaveAxes(graph,yw,PlyYaxName,PlyXaxName)
		obj += "\"xref\":\""+PlyXaxName+"\",\r"
		obj += "\"yref\":\""+PlyYaxName+"\",\r"
		obj += "\"x\":"+dub2str(xpos)+",\r"
		obj += "\"y\":"+dub2str(ypos)+",\r"
		obj += "\"ax\":"+dub2str(ax)+",\r"
		obj += "\"ay\":"+dub2str(ay)+",\r"		
		string LblTxt = stringbykey("TEXT",info, ":",";",1)
		String altFont //= ExtractFont(LblTxt) //Try to read a font escape code, and extract it if it exists
		variable altFontSize,OZ // = ExtractFontSize(LblTxt) //Try to read a font size escpe code, and extract if it exists
		variable num = 0
		if (strsearch(lbltxt,"\OZ",0)>-1) //Oh gosh, this is an auto text equal to the z-value of a contour.
			variable pos = strsearch(yw,"=",0)
			string temp = yw[pos+1,strlen(yw)-1]
			num = str2num(temp)
			lbltxt = num2str(num)
		endif
				
		LblTxt = ProcessText(LblTxt,altFont,altFontsize,OZ,OZval=num) //For tags, there is a possibility that we have an /OZ flag, so we need to send the trace name
		obj += "\"text\":\""+LblTxt+"\",\r"
	else //Plain text box-specific things--------------------------------------------------------------------------------------------------------------------------------
		obj += "{\r"
		obj += "\"showarrow\":false,\r"
		obj += "\"xref\":\"paper\",\r"
		obj += "\"yref\":\"paper\",\r"
		absx = str2num(stringbykey("ABSX",info,":",";",1))
		absy = str2num(stringbykey("ABSY",info,":",";",1))
		fracx = (absx-p_left)/(p_right-p_left)
		fracy = (absy-p_bottom)/(p_top-p_bottom)
		obj += "\"x\":"+dub2str(fracx)+",\r"
		obj += "\"y\":"+dub2str(fracy)+",\r"
		LblTxt = stringbykey("TEXT",info, ":",";",1)
//		altFont //= ExtractFont(LblTxt) //Try to read a font escape code, and extract it if it exists
//	 	altFontSize,OZ // = ExtractFontSize(LblTxt) //Try to read a font size escpe code, and extract if it exists
		LblTxt = ProcessText(LblTxt,altFont,altFontsize,OZ)
		obj += "\"text\":\""+LblTxt+"\",\r"
	endif //Now do generic things--------------------------------------------------------------------------------------------------------------------------------------------
		anchorcode = stringbykey("A",flags,"=","/",1)
		BackCode = stringbykey("B",flags,"=","/",1)
		DFlag = stringbykey("D",flags,"=","/",1)
		exterior = stringbykey("E",flags,"=","/",1)
		Frame = str2num(stringbykey("F",flags,"=","/",1))
		Rotation = str2num(stringbykey("O",flags,"=","/",1))
		txtColor = "txtcolor(x)="+stringbykey("G",flags,"=","/",1) //prepend a string used to search in the standard way
		
		if(!(Rotation==0))
			obj += "\"textangle\":"+num2str(-Rotation)+",\r"
		endif
		obj += AnchorText(anchorcode)
		if (frame == 2)  //Draw a border
			if (strsearch(Dflag,"{",0) >-1)  //Uh oh, we have a fancy flag..take just thefirst number, the actual borderwidth
				Dflag = "dflag(x)="+Dflag
				Dflag = dub2str(GetNumFromModifyStr(Dflag,"dflag","{",0))
			endif	
		elseif (frame == 0) //Don't draw a border
			dflag="0"
		endif
		obj += "\"borderwidth\":"+dflag+",\r"
//		string framesize = stringbykey("frame",info,"=",",")
//		obj += "\"outlinewidth\":"+framesize+",\r"
		
		if (stringmatch(backcode[0],"(")) //The background code is a color
			backcode = "bgcolor(x)="+backcode	//Add a key for the standard format for the key searcher
			rgbR = round(GetNumFromModifyStr(backcode,"bgcolor","(",0)/257)
			rgbG = round(GetNumFromModifyStr(backcode,"bgcolor","(",1)/257)
			rgbB = round(GetNumFromModifyStr(backcode,"bgcolor","(",2)/257)	
			rgbA = 1
		elseif (str2num(backcode) == 1 ) //transparent background
			rgbR = 0
			rgbG = 0
			rgbB = 0
			rgbA = 0
		elseif (str2num(backcode) == 2 ) //Graph area color
			WMGetGraphPlotBkgColor(graph, rgbR, rgbG, rgbB)
			rgbR = round(rgbR/257)
			rgbG = round(rgbG/257)
			rgbB = round(rgbB/257)
			rgbA=1
			endif	
		obj +=  "\"bgcolor\":\"rgba("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+","+dub2str(rgbA)+")\",\r"
		string DefaultFnt = GetDefaultFont(graph)
		variable DefaultTextSize_pt = GetDefaultFontSize(graph,"") //This number is returned in POINTS
		//TEXT----------------------------------------------------------------------------------------------------------------------------------------
		rgbR = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",0)/257)
		rgbG = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",1)/257)
		rgbB = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",2)/257)	

		obj += "\"font\":{\r"
		obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
		if (!stringmatch(altFont,"default"))
			obj += "\"family\":\""+altFont+"\",\r"
		endif
		if (AltFontSize>0)
			obj += "\"size\":"+num2str(txt2px(AltFontSize))+",\r"
		endif
		obj = obj[0,strlen(obj)-3]
		obj += "\r},\r"
		obj +=  "\"bordercolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
		
	obj = obj[0,strlen(obj)-3]
	obj += "\r},\r"
	return obj	
end


static Function PLYParseTagForLine(win,name) //Igor bug: line information not returned in annotationInfo! Have to parse recreation macro
	String win,name	// input
	String key="Tag/C/N="+name
	String commands= WinRecreation(win,4) 
	Variable start= strsearch(commands, key, 0)
		if( start > 0 )
			Variable last= strsearch(commands, "/L=", start)
			if( last > start )
				variable cma = strsearch(commands, "/",last+1)
				variable spc =  strsearch(commands, " ",last+1)
				variable finish 
				if (cma<0)
					finish = spc
				elseif (spc <0)
					finish = cma
				else
					finish = min(spc,cma)
				endif
				String Line = commands[last+3,finish]	// "65535,65534,49151"
				return str2num(Line)
			endif
		endif
	
	return (2) //The defualt tag is an arrow.
End


static function/T CreateLegendObj(Name,graph,IsLegend)
	string name,graph
	variable &isLegend //Set this flag to 1 if  we make a legend, because otherwise we need to disable the legend in the plotly graph, which is on by default.
	string info = annotationinfo(graph,name,1)
//	IgorNB(info+"\r\r")
	string Type =  stringbykey("TYPE",info,":",";",1)
	string obj = ""
	string Flags = stringbyKey("FLAGS",info,":",";",1)
	string anchorCode,BackCode,DFlag,TxtColor,Rotation,exterior,Xpos,Ypos
	variable absX,absY,fracx,fracy
	getwindow $graph, gsize //Look up the size of the graph window, in points
	variable g_left = V_left
	variable g_right = V_right
	variable g_top = V_top
	variable g_bottom = V_bottom
	getwindow $graph, psize //look up the plot size in points
	variable p_left = V_left
	variable p_right = V_right
	variable p_top = V_top
	variable p_bottom = V_bottom
	variable rgbR,rgbG,rgbB,rgbA,Frame
	
	if (stringmatch(type,"Legend") ) //Get the legend object started.
		islegend = 1  //Set the legend flag
		obj += "\"legend\":{\r"
	else
		return ""
	endif
		anchorcode = stringbykey("A",flags,"=","/",1)
		BackCode = stringbykey("B",flags,"=","/",1)
		DFlag = stringbykey("D",flags,"=","/",1)
		exterior = stringbykey("E",flags,"=","/",1)
		Frame = str2num(stringbykey("F",flags,"=","/",1))
		txtColor = "txtcolor(x)="+stringbykey("G",flags,"=","/",1) //prepend a string used to search in the standard way
		xpos = stringbykey("X",flags,"=","/",1)
		ypos = stringbykey("Y",flags,"=","/",1)
		absx = str2num(stringbykey("ABSX",info,":",";",1))
		absy = str2num(stringbykey("ABSY",info,":",";",1))
		fracx = (absx-p_left)/(p_right-p_left)
		fracy = (absy-p_bottom)/(p_top-p_bottom)
		obj += "\"x\":"+dub2str(fracx)+",\r"
		obj += "\"y\":"+dub2str(fracy)+",\r"
		obj += AnchorText(anchorcode)
		if (frame == 2)  //Draw a border
			if (strsearch(Dflag,"{",0) >-1)  //Uh oh, we have a fancy flag..take just thefirst number, the actual borderwidth
				Dflag = "dflag(x)="+Dflag
				Dflag = dub2str(GetNumFromModifyStr(Dflag,"dflag","{",0))
			endif	
		elseif (frame == 0) //Don't draw a border
			dflag="0"
		endif
		obj += "\"borderwidth\":"+dflag+",\r"
//		string framesize = stringbykey("frame",info,"=",",")
//		obj += "\"outlinewidth\":"+framesize+",\r"
		
		if (stringmatch(backcode[0],"(")) //The background code is a color
			backcode = "bgcolor(x)="+backcode	//Add a key for the standard format for the key searcher
			rgbR = round(GetNumFromModifyStr(backcode,"bgcolor","(",0)/257)
			rgbG = round(GetNumFromModifyStr(backcode,"bgcolor","(",1)/257)
			rgbB = round(GetNumFromModifyStr(backcode,"bgcolor","(",2)/257)	
			rgbA = 1
		elseif (str2num(backcode) == 1 ) //transparent background
			rgbR = 0
			rgbG = 0
			rgbB = 0
			rgbA = 0
		elseif (str2num(backcode) == 2 ) //Graph area color
			WMGetGraphPlotBkgColor(graph, rgbR, rgbG, rgbB)
			rgbR = round(rgbR/257)
			rgbG = round(rgbG/257)
			rgbB = round(rgbB/257)
		endif	
		obj +=  "\"bgcolor\":\"rgba("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+","+dub2str(rgbA)+")\",\r"
		string DefaultFnt = GetDefaultFont(graph)
		variable DefaultTextSize_pt = GetDefaultFontSize(graph,"") //This number is returned in POINTS
		//Axis Label/Title----------------------------------------------------------------------------------------------------------------------------------------
		rgbR = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",0)/257)
		rgbG = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",1)/257)
		rgbB = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",2)/257)	
		string LblTxt = stringbykey("TEXT",info, ":",";",1)
		String altFont //= ExtractFont(LblTxt) //Try to read a font escape code, and extract it if it exists
		variable altFontSize,OZ // = ExtractFontSize(LblTxt) //Try to read a font size escpe code, and extract if it exists
		LblTxt = ProcessText(LblTxt,altFont,altFontsize,OZ)
		obj += "\"text\":\""+LblTxt+"\",\r"
		obj += "\"font\":{\r"
		obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
		if (!stringmatch(altFont,"default"))
			obj += "\"family\":\""+altFont+"\",\r"
		endif
		if (AltFontSize>0)
			obj += "\"size\":"+num2str(txt2px(AltFontSize))+",\r"
		endif
		obj = obj[0,strlen(obj)-3]
		obj += "\r},\r"
		obj +=  "\"bordercolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	obj = obj[0,strlen(obj)-3]
	obj += "\r},\r"
	return obj
end

//Create a Color Scale-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
static function/T CreateColorScaleObj(Name,graph,trace)
	string Name,Graph,trace
//	variable typeFlag=0 //Type flag is 1 for all types other than colorscales, or 0 for colorscale.  That is because colorscale has to go in with the image objects
	string info = annotationinfo(graph,name,1)
	IgorNB(info+"\r\r")
	string Type =  stringbykey("TYPE",info,":",";",1)
	string obj = ""
	string Flags = stringbyKey("FLAGS",info,":",";",1)
	string anchorCode,BackCode,DFlag,TxtColor,Rotation,exterior,Xpos,Ypos
	variable BarWidth, Frame
	variable absX,absY,fracx,fracy
	getwindow $graph, gsize //Look up the size of the graph window, in points
	variable g_left = V_left
	variable g_right = V_right
	variable g_top = V_top
	variable g_bottom = V_bottom
	getwindow $graph, psize //look up the plot size in points
	variable p_left = V_left
	variable p_right = V_right
	variable p_top = V_top
	variable p_bottom = V_bottom
	variable rgbR,rgbG,rgbB,rgbA
	
//	if (TypeFlag==1 && stringmatch(type,"ColorScale" ) )  //They want non-color scale, but this annotaion is a color scale
//		return ""
	if (!stringmatch(type,"ColorScale") ) //They want a color scale, but this annotation is not a color scale
		return ""
	else //if (stringmatch(type,"ColorScale"))	//They want a color scale, and this is a color scale.  So return information
		string Ywave = stringbykey("YWAVE",info,":",";",1)
		if (!stringmatch(Ywave,trace)) //Actually, this isn't the color scale we wanted...skip it
			return ""
		endif
		obj += "\"colorbar\": {\r"
		anchorcode = stringbykey("A",flags,"=","/",1)
		BackCode = stringbykey("B",flags,"=","/",1)
		DFlag = stringbykey("D",flags,"=","/",1)
		exterior = stringbykey("E",flags,"=","/",1)
		Frame = str2num(stringbykey("F",flags,"=","/",1))
		txtColor = "txtcolor(x)="+stringbykey("G",flags,"=","/",1) //prepend a string used to search in the standard way
		
		xpos = stringbykey("X",flags,"=","/",1)
		ypos = stringbykey("Y",flags,"=","/",1)
		absx = str2num(stringbykey("ABSX",info,":",";",1))
		absy = str2num(stringbykey("ABSY",info,":",";",1))
		fracx = (absx-p_left)/(p_right-p_left)
		fracy = (absy-p_bottom)/(p_top-p_bottom)
		obj += "\"x\":"+dub2str(fracx)+",\r"
		obj += "\"y\":"+dub2str(fracy)+",\r"
		obj += AnchorText(anchorcode)
		
		string csinfo = stringbykey("COLORSCALE",info,":",";",1)
		variable width = str2num(stringbykey("width",csinfo,"=",",",1))
		variable widthpct = str2num(stringbykey("widthPct",csinfo,"=",",",1))/100
		variable length = str2num(stringbykey("height",csinfo,"=",",",1))
		variable lengthpct = str2num(stringbykey("heightPct",csinfo,"=",",",1))/100		
		if ( (width==0) && (widthpct==0)) //Default width
			obj += "\"thickness\":"+dub2str(round(15*screenresolution/72))+",\r"
			obj += "\"thicknessmode\":\"pixels\",\r"
		elseif (width>0)
			obj += "\"thickness\":"+dub2str(round(width*screenresolution/72))+",\r"
			obj += "\"thicknessmode\":\"pixels\",\r"
		else
			obj += "\"thickness\":"+dub2str(widthpct)+",\r"
			obj += "\"thicknessmode\":\"fraction\",\r"
		endif
				
		if ((length == 0) && (lengthpct==0) )
			obj += "\"len\":"+dub2str(0.75)+",\r" //Igor's default CS height
			obj += "\"lenmode\":\"fraction\",\r"
		elseif (length>0)
			obj += "\"len\":"+dub2str(round(length*screenresolution/72))+",\r"
			obj += "\"lenmode\":\"pixels\",\r"
		else
			obj += "\"len\":"+dub2str(lengthpct)+",\r"
			obj += "\"lenmode\":\"fraction\",\r"
		endif
		
		
		if (frame == 2)  //Draw a border
			if (strsearch(Dflag,"{",0) >-1)  //Uh oh, we have a fancy flag..take just thefirst number, the actual borderwidth
				Dflag = "dflag(x)="+Dflag
				Dflag = dub2str(GetNumFromModifyStr(Dflag,"dflag","{",0))
			endif	
		elseif (frame == 0) //Don't draw a border
			dflag="0"
		endif
		obj += "\"borderwidth\":"+dflag+",\r"
		string framesize = stringbykey("frame",info,"=",",")
		obj += "\"outlinewidth\":"+framesize+",\r"
		if (stringmatch(backcode[0],"(")) //The background code is a color
			backcode = "bgcolor(x)="+backcode	//Add a key for the standard format for the key searcher
			rgbR = round(GetNumFromModifyStr(backcode,"bgcolor","(",0)/257)
			rgbG = round(GetNumFromModifyStr(backcode,"bgcolor","(",1)/257)
			rgbB = round(GetNumFromModifyStr(backcode,"bgcolor","(",2)/257)	
			rgbA = 1
		elseif (str2num(backcode) == 1 ) //transparent background
			rgbR = 0
			rgbG = 0
			rgbB = 0
			rgbA = 0
	//	elseif (str2num(backcode) == 2 ) //Graph area color
	//		rgbR = 255
	//		rgbG = 255
	//		rgbB = 255
	//		ExtractRGB(rgbR,rgbG,rgbB,"gbRGB",graph) //A function that looks up colors from the graph recreation macro, the only way I can find to get this info
		endif	
		obj +=  "\"bgcolor\":\"rgba("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+","+dub2str(rgbA)+")\",\r"
				
		string DefaultFnt = GetDefaultFont(graph)
		variable DefaultTextSize_pt = GetDefaultFontSize(graph,"") //This number is returned in POINTS
		//Axis Label/Title----------------------------------------------------------------------------------------------------------------------------------------
		
		rgbR = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",0)/257)
		rgbG = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",1)/257)
		rgbB = round(GetNumFromModifyStr(txtcolor,"txtcolor","(",2)/257)	
		obj += "\"tickcolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
		
		string LblTxt = stringbykey("TEXT",info, ":",";",1)
		String altFont //= ExtractFont(LblTxt) //Try to read a font escape code, and extract it if it exists
		variable altFontSize,OZ // = ExtractFontSize(LblTxt) //Try to read a font size escpe code, and extract if it exists
		LblTxt = ProcessText(LblTxt,altFont,altFontsize,OZ)
		obj += "\"tickfont\":{\r"
		obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	
		//NOTE: Tick labels are always default font and default  size.
//		if (!stringmatch(altFont,"default"))
//			obj += "\"family\":\""+altFont+"\",\r"
//		endif
//		if (AltFontSize>0)
//			obj += "\"size\":"+num2str(txt2px(AltFontSize))+",\r"
//		endif
		obj = obj[0,strlen(obj)-3]
		obj+="\r},\r"		
		string nticks = stringbykey("nticks",csinfo,"=",",",1)
		variable ticklen = str2num(stringbykey("tickLen",csinfo,"=",",",1))
		string tickthick =stringbykey("tickThick",csinfo,"=",",",1)
		obj += "\"nticks\":"+nticks+",\r"
		
		if (tickLen == -1) //Auto = 0.7 Text size
			tickLen = 0.7*(txt2px(DefaultTextSize_pt))
			obj += "\"ticks\":\"outside\",\r"
		elseif (tickLen>-1)  //Normal outside ticks
			obj += "\"ticks\":\"outside\",\r"
		elseif (tickLen < -50) //Inside ticks
			obj += "\"ticks\":\"inside\",\r"
			ticklen = -(ticklen + 50)
		else //should have been crossing, make them outside, I guess
			obj += "\"ticks\":\"outside\",\r"
			ticklen = -ticklen
		endif
		obj += "\"ticklen\":"+dub2str(tickLen)+",\r"
		obj += "\"tickwidth\":"+tickThick+",\r"
		obj += "\"title\":\""+LblTxt+"\",\r"
		obj += "\"titleside\":\"right\",\r"
		obj += "\"titlefont\":{\r"
		if (!stringmatch(altFont,"default"))
			obj += "\"family\":\""+altFont+"\",\r"
		endif
		if (AltFontSize>0)
			obj += "\"size\":"+num2str(txt2px(AltFontSize))+",\r"
		endif
		//Do Text and colorbar fram color.  They are the same unless a flag is set, so keep this group together.
		obj += "\"color\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
		obj = obj[0,strlen(obj)-3]
		obj += "\r},\r"
		variable Fri = strsearch(csInfo,"frameRGB",0)
		if (Fri > -1)
			variable FrEnd = strsearch(csInfo,")",Fri+1)
			string FrameRGB = "frameRGB(x)="+csInfo[Fri+9,FrEnd]
			rgbR = round(GetNumFromModifyStr(FrameRGB,"frameRGB","(",0)/257)
			rgbG = round(GetNumFromModifyStr(FrameRGB,"rameRGB","(",1)/257)
			rgbB = round(GetNumFromModifyStr(FrameRGB,"rameRGB","(",2)/257)	
		endif
		obj +=  "\"outlinecolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
		obj = obj[0,strlen(obj)-3]
		obj += "\r},\r"
		obj += "\"showscale\":true,\r"
	endif	
	return obj
end

Function PlotlySetUser([user,key])
	string user, key
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Plotly			// Make sure this exists.
	if(!paramisdefault(user))
		string/G root:Packages:Plotly:userName = user
	endif
	if(!paramisdefault(key))
		string/G root:Packages:Plotly:userKey = key
	endif
end

Function jbmUser()
	string user, key
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Plotly			// This line just makes sure this data folder exists.
	string/G root:Packages:Plotly:userName = "jbmiller"
	string/G root:Packages:Plotly:userKey = "q54syzx270"
end

menu "Graph"
	"Graph2Plotly/1"
end

Function Graph2Plotly([graph,plotlyGraph,plotlyFolder,skipSend,keepCMD])	
	string graph, PlotlyGraph, PlotlyFolder
	variable skipSend //Set this flag to make the notebook without sending the graph
	variable KeepCMD //Default is to kill the CMD window after use, but we can keep it to look at it if we want
	
	if(paramisdefault(PlotlyFolder) )
		PlotlyFolder = IgorInfo(1) //If the user doesn't specify a folder, use the name of the experiment. 
	endif
	if(paramisdefault(skipSend))
		skipsend=0
	endif	
	if(paramisdefault(KeepCMD))
		KeepCMD = 0
	endif
	if (paramisdefault(graph))  //No graph name was specified, use the top graph
		graph = WinName(0,1)  //This explicitly assigns the name of the top graph to graph
	endif
	dowindow $graph  //Make sure the graph exists and quit if it doesn't 
	if (V_flag==0)
		print "No Such Graph"
		return -1
	endif
	
	//We're going to store a bunch of stuff about the graph in the Plotly data folder. This won't confict with any user stuff.
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Plotly			// Make sure this exists.
	string/G root:Packages:Plotly:HaxisList = ""  //Store some global axis variables
	string/G root:Packages:Plotly:VaxisList = ""
	variable/G root:Packages:Plotly:SizeMode = 0  //use to Store the size range of the igor graph  for autosizing various features.
	variable/G root:Packages:Plotly:DefautTextSize
	variable/G root:Packages:Plotly:DefaultTickLength
	variable/G root:Packages:Plotly:DefaultMarkerSize //In Igor size, not points
	variable/G  root:Packages:Plotly:MarkerFlag = 0		//Set this flag to adjust "axis standoff"...it tells us whether we have marerks or not
	variable/G  root:Packages:Plotly:LargestMarkerSize = 0	//Set is the largest actual marker size we use, which we need to know for axis standoff, or padding  Units are px
	variable/G root:Packages:Plotly:Standoff = 0
	variable/G root:Packages:Plotly:HL=0	// are the four standoff correction variables
	variable/G root:Packages:Plotly:HR=0
	variable/G root:packages:Plotly:VT=0
	variable/G root:packages:Plotly:VB=0
	string/G root:packages:Plotly:BarToMode="NULL" 	//For Plotly, we need to keep track of the grouping mode for Bars. 
	variable/G root:packages:Plotly:CatCount=0			//Plotly category graphs need to be scaled based on the number of bars. Keep track
	variable/G root:packages:Plotly:TraceOrderFlag=0
	variable/G root:packages:Plotly:catGap=-1
	variable/G root:packages:Plotly:barGap=-1
	SVAR HaxisList = root:Packages:Plotly:HaxisList
	SVAR VaxisList = root:Packages:Plotly:VaxisList
	NVAR SizeMode = root:Packages:Plotly:SizeMode
	NVAR DefaultTextSize = root:Packages:Plotly:DefautTextSize
	NVAR DefaultTickLength = root:Packages:Plotly:DefaultTickLength
	NVAR DefaultMarkerSize = root:Packages:Plotly:DefaultMarkerSize //In Igor size, not points	
	NVAR MarkerFlag = root:Packages:Plotly:MarkerFlag
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize
	NVAR Standoff = root:Packages:Plotly:Standoff //If any axis has an axis standoff, then set this variable to 1, and use Plotly padding to avoid covering the marker
	NVAR HL = root:Packages:Plotly:HL
	NVAR HR = root:Packages:Plotly:HR
	NVAR VT = root:Packages:Plotly:VT
	NVAR VB = root:Packages:Plotly:VB
	NVAR catGap = root:Packages:Plotly:catGap
	NVAR barGap = root:Packages:Plotly:barGap
	SVAR barToMode = root:packages:Plotly:BarToMode
	NVAR TraceOrderFlag = root:packages:Plotly:TraceOrderFlag
	SVAR/Z user = root:packages:Plotly:UserName
	if(!SVAR_Exists(user))
		print "Please use  PlotlySetUser([user=\"UserName\",key=\"xxxxxxxxxx\"]) to set User and/or Key"
		return -1
	endif
	SVAR/Z key = root:packages:Plotly:UserKey
	if(!SVAR_Exists(key))
		print "Please use  PlotlySetUser([user=\"UserName\",key=\"xxxxxxxxxx\"]) to set User and/or Key"
		return -1
	endif

	string list 

	if(paramisdefault(PlotlyGraph)) //User did not specify a name for the Plotly graph...use the Igor name
		PlotlyGraph = graph
	endif

	getwindow $graph, gsizeDC //Look up the size of the graph window, in pixels
	variable Wheight = V_bottom - V_top
	variable Wwidth = V_right - V_left
	variable SizeLimiter = min(wHeight,Wwidth)
	variable win_bot = V_bottom
	variable win_top = V_top
	variable win_left = V_left
	variable win_right = V_right
	string info
	//Now set the Igor graph size flag:
//		Graph Size	Text Size	Tick Length	Marker Size
//	1 < 267px		9pt			8pt			5 pt (inside dimension, so Igor size would be 2, because 2*2 + 1 = 5)
//	2 < 467px		10pt			9pt			7 pt
//	3 < 667px		12pt			11pt			9pt
//	4 < 801px		14pt			13pt			13pt
//	5 >800px		18pt			16pt			15pt
	if (SizeLimiter < 267)
		SizeMode = 1
		DefaultTextSize = 9
		DefaultTickLength = 8
		DefaultMarkerSize = 2
	elseif(SizeLimiter < 467)
		SizeMode = 2
		DefaultTextSize = 10
		DefaultTickLength = 9
		DefaultMarkerSize = 3
	elseif(SizeLimiter < 667)
		SizeMode = 3
		DefaultTextSize = 12
		DefaultTickLength = 11
		DefaultMarkerSize = 4
	elseif(SizeLimiter < 801)
		SizeMode = 4
		DefaultTextSize = 14
		DefaultTickLength = 13
		DefaultMarkerSize = 13
	else
		SizeMode = 5
		DefaultTextSize = 18
		DefaultTickLength = 16
		DefaultMarkerSize = 15
	endif
	
	string PlyName = graph+"_CMD"

	//Create the notebook and add header info
	doWindow $PlyName  //This will set v_flag to 0 if the window does not exist
	if(v_flag)
		dowindow/K $PlyName    //If the window already exists, kill it
	endif
	Newnotebook/N=$PlyName/F=0
	
	if (stringmatch(user,""))
		print "Please use  PlotlySetUser([user=\"UserName\",key=\"xxxxxxxxxx\"]) to set User and/or Key"
		return -1
	endif
	if (stringmatch(key,""))
		print "Please use  PlotlySetUser([user=\"UserName\",key=\"xxxxxxxxxx\"]) to set User and/or Key"
		return -1
	endif
	string Plyun = "un="+user+"&\r"
	string Plykey = "key="+key+"&\r"
	//string platform = "platform=Igor,version=0.0&\r"
	string platform = "platform=Igor&\r"
	Notebook $PlyName text=Plyun+Plykey+platform
	oPlyString(PlyName,"origin=plot&\r")  //For now assume it is a graph

//DATA--------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	//_____________Args
	oPlyString(PlyName,"args=[\r")
	variable index = 0
	string traceName
	string obj = ""
	
//IMAGES-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	list = ImageNameList(graph, ";")
	do			//Step through all traces on Graph
		traceName = stringFromList(index,list)
		if (strlen(traceName) == 0)
			break //no more traces, so move on to next section
		endif
		//Now make a trace object
		Obj += CreateImageObj(traceName,graph) + ",\r"
//		if(index>0)  //If we are making more than one trace object, we need a comma
//			oPlyString(PlyName,",\r")
//		endif
//		oPlyString(PlyName,Obj)
		index += 1
	while (1)

//CONTOURS-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	list = contourNameList(graph, ";")
	index=0
	do			//Step through all traces on Graph
		traceName = stringFromList(index,list)
		if (strlen(traceName) == 0)
			break //no more traces, so move on to next section
		endif
		//Now make a trace object
		Obj += CreateContourObj(traceName,graph) + ",\r"
//		if(index>0)  //If we are making more than one trace object, we need a comma
//			oPlyString(PlyName,",\r")
//		endif
//		oPlyString(PlyName,Obj)
		index += 1
	while (1)
	
//TRACES------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	//There are a couple of cases when we need to change the order of the traces for Plotly: stacked bar charts, and fill to next scatter plots.

	make/FREE/O/T/N=0 TraceObjectWave	//We'll store all the traces in this wave, then sort them if needed, THEN write them to the plotly output
	list = TraceNameList(graph, ";", 1 )
	index=0
	do			//Step through all traces on Graph
		traceName = stringFromList(index,list)
		if (strlen(traceName) == 0)
			break //no more traces, so move on to next section
		endif
		//Now make a trace object
		insertpoints index,1,TraceObjectWave
		TraceObjectWave[index] = CreateTrObj(traceName,graph)
		index += 1
	while (1)
	if (index>0) //Make sure there are more than 0 traces before we try to write any
		oPlyString(PlyName,Obj) //First write the image part, INCLUDING the comma
		variable numTraces = index
		if (TraceOrderFlag) //Reverse the order
			duplicate/O/Free/T TraceObjectWave TempTOW
			TraceObjectWave = TempTOW[numTraces-p-1]
		endif		
		index=0
		do  //Output the data to the notebook
			oPlyString(PlyName,TraceObjectWave[index])
			if (index < numTraces-1)
				oPlyString(plyName,",\r") //Need a comma between traces, but not after the  last trace
			endif
			index += 1
		while (index < numTraces)
	else	//No traces, write the images but first get rid of the comma
		obj = obj[0,strlen(obj)-3]
		oPlyString(PlyName,Obj)
	endif

	oPlyString(PlyName,"\r]&\r")
//LAYOUT---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//_____________kwArgs
	if (stringmatch(PlotlyFolder,"") )
		obj = "kwargs={\r\"filename\":\""+PlotlyGraph+"\",\r\"fileopt\":\"overwrite\",\r"
	else
		obj = "kwargs={\r\"filename\":\""+PlotlyFolder+"/"+PlotlyGraph+"\",\r\"fileopt\":\"overwrite\",\r"
	endif
	obj += "\"layout\" : {\r"

	getwindow $graph, psizeDC //Set up the graph margins
	variable pheight = V_bottom - V_top
	variable pwidth = V_right - V_left
	variable p_bottom = V_bottom
	variable p_top = v_top
	variable p_left = v_left
	variable p_right = v_right
	variable m_L = p_left - win_left
	variable m_R = win_right - p_right
	variable m_T = p_top - win_top
	variable m_B = win_bot - p_bottom
	
	//We need to plan ahead and figure out if we need any standoff axes before we go and set the scales.  We only need to check the four main axes
	If (findlistitem("left",Vaxislist)>-1)
		info = AxisInfo(graph, "left")
		if (GetNumFromModifyStr(info,"standoff","",0)==1) //Standoff IS enabled
			HL = LargestMarkerSize*2												//changed from /2 to *2 because of apparent marker size changes
			if (GetNumFromModifyStr(info,"mirror","",0)>0) //Need to adjust mirror too
				HR = LargestMarkerSize*2
			endif
		endif
	endif
	if(findlistitem("right",Vaxislist)>-1)
		info = AxisInfo(graph, "right")
		if (GetNumFromModifyStr(info,"standoff","",0)==1) //Standoff IS enabled
			HR = LargestMarkerSize*2
			if (GetNumFromModifyStr(info,"mirror","",0)>0) //Need to adjust mirror too
				HL = LargestMarkerSize*2
			endif
		endif
	endif
	if(findlistitem("top",Haxislist)>-1)
		info = AxisInfo(graph, "top")
		if (GetNumFromModifyStr(info,"standoff","",0)==1) //Standoff IS enabled
			VT = LargestMarkerSize*2
			if (GetNumFromModifyStr(info,"mirror","",0)>0) //Need to adjust mirror too
				VB = largestMarkerSize*2
			endif
		endif
	endif
	if(findlistitem("bottom",Haxislist)>-1)
		info = AxisInfo(graph, "bottom")
		if (GetNumFromModifyStr(info,"standoff","",0)==1) //Standoff IS enabled
			VB = LargestMarkerSize*2
			if (GetNumFromModifyStr(info,"mirror","",0)>0) //Need to adjust mirror too
				VT = largestMarkerSize*2
			endif
		endif
	endif
			
	//Step through the AXES-------------------------
	index=0
	string PlyAxName
	do			//First Step through horizontal axes on Graph
		string axisname = stringFromList(index,Haxislist)
		if (strlen(axisName) == 0)
			break //no more axes, so move on to next section
		endif
		if (index>0)
			PlyAxName = "xaxis"+dub2str(index+1)
		else
			PlyAxName = "xaxis"
		endif
		Obj += CreateAxisObj(AxisName,PlyAxName,graph,"H",index) 
		index += 1
	while (1)
	index=0
	do			//The Step through vertical axes on Graph
		axisname = stringFromList(index,Vaxislist)
		if (strlen(axisName) == 0)
			break //no more axes, so move on to next section
		endif
		if (index>0)
			PlyAxName = "yaxis"+dub2str(index+1)
		else
			PlyAxName = "yaxis"
		endif
		Obj += CreateAxisObj(AxisName,PlyAxName,graph,"V",index)
		index += 1
	while (1)

	if(!stringmatch(BarToMode,"NULL"))
		obj += "\"barmode\":\""+BarToMode+"\",\r"
	endif
	if (catGap > -1) //these variables are initialized to -1, so if they are bigger, they have been set and we need to send them.  Otherwise, don't clutter.
		obj += "\"bargap\":"+dub2str(catGap)+",\r"
	endif
	if (barGap > -1)
		obj += "\"bargroupgap\":"+dub2str(barGap)+",\r"
	endif

//Look for a Legend ---------------------------------------------------------------------------------------------------------------------------------------------------
	list = annotationlist(graph)
	index=0
	string AnnotationName
	variable CreateLegend=0
	do		//Step through the annotations looking for a legend
		AnnotationName = stringFromList(index,List)
		if (strlen(AnnotationName) == 0)
			break //no more axes, so move on to next section
		endif
		Obj += CreateLegendObj(AnnotationName,graph,CreateLegend)
		index += 1
	while (1)
	if (CreateLegend)
		obj += "\"showlegend\":true,\r"
	else
		obj += "\"showlegend\":false,\r"
	endif
	
	index=0
	string AnnObj = "" 
	do		//Step through the annotations looking for note-types for Plotly. These have their own section in plotly, so we have to step through agian
		AnnotationName = stringFromList(index,List)
		if (strlen(AnnotationName) == 0)
			break //no more axes, so move on to next section
		endif
		AnnObj += CreateAnnotationObj(AnnotationName,graph)
		index += 1
	while (1)
	AnnObj = AnnObj[0,strlen(annObj)-3]
	if (!stringmatch(AnnObj,""))
		obj += "\"annotations\":[\r"
		obj += AnnObj
		obj += "\r],\r"
	endif

	obj += "\"height\":"+dub2str(Wheight+45)+",\r"
	obj += "\"width\":"+dub2str(Wwidth+20)+",\r"
	obj += "\"autosize\":false,\r"

	obj += "\"margin\": {\r"
	obj += "\"l\" : "+ dub2str(m_L+10) +",\r"  //The +10 is a kludge because text position can't be set in Plotly
	obj += "\"r\" : "+ dub2str(m_R+10) +",\r"
	obj += "\"t\" : "+ dub2str(m_T+10+25) +",\r"	//Add extra 25 for the little Plotly buttons
	obj += "\"b\" : "+ dub2str(m_B+10) +",\r"	
	obj = obj[0,strlen(obj)-3]
	obj += "\r},\r"

	//Done stepping through the AXES
	//Graph colors---------------------------------------------------------------------------------------------------------------------------------------------
	variable rgbR,rgbG,rgbB
	WMGetGraphPlotBkgColor(graph, rgbR, rgbG, rgbB)
	rgbR = round(rgbR/257)
	rgbG = round(rgbG/257)
	rgbB = round(rgbB/257)
	obj += "\"plot_bgcolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	WMGetGraphWindowBkgColor(graph, rgbR, rgbG, rgbB)
	rgbR = round(rgbR/257)
	rgbG = round(rgbG/257)
	rgbB = round(rgbB/257)
	obj += "\"paper_bgcolor\":\"rgb("+dub2str(rgbR)+","+dub2str(rgbG)+","+dub2str(rgbB)+")\",\r"
	obj += "\"separators\":\".\",\r"
	//Set Graph default font information
	string DefaultFontFamily = getdefaultFont(graph)
	variable DefaultFontSize = getdefaultfontsize(graph,"")
	obj += "\"font\":{\r"
	obj += "\"family\":\""+defaultFontFamily+"\",\r"
	obj += "\"size\":"+dub2str(Txt2Px(DefaultFontSize))+",\r"
	obj += "\"color\":\"rgb(0, 0, 0)\"\r"
	obj += "},\r"

	obj = obj[0,strlen(obj)-3]
	obj += "\r},\r"  //End of Layout
	obj = obj[0,strlen(obj)-3]
	obj += "\r}"  //End of KWARGS
	oPlyString(PlyName,obj)
//	saveexperiment //Protect the experiment from a bad internet connection...
	
	if (!skipsend) //Send the data to Plotly unless asked not to
		Notebook $PlyName getData=2
		string s_Post = Strip (s_value)
		easyHTTP /Post=s_post "http://plot.ly/clientresp"
		print s_Gethttp
	endif
	
	if(!keepCMD)
		dowindow/K $PlyName
	endif
	
	return 1
end

static function IgorNB(str,[IgrName])
	string str,IgrName
	if (paramisdefault(IgrName))
		IgrName = "IgrGraphNB"
	endif
	dowindow $IgrName
	if (V_flag==0)
		newnotebook/N=$IgrName
	endif
	Notebook $IgrName, text=str
end

static function NewPlyNB(PlyName)	//Make a new notebook to get ready for Ploty-formated commands, and add the default commands
	string PlyName
	doWindow $PlyName  //This will set v_flag to 0 if the window does not exist
	if(v_flag)
		dowindow/K $PlyName    //If the window already exists, kill it
	endif
	Newnotebook/N=$PlyName/F=0
	oDefaultPlyInfo(PlyName)
end	

static function oPlyString(PlyName,Str)
	string PlyName,Str
	doWindow $PlyName
	if(!v_Flag) //The  window does not exist
		print "Please create this Ply Window first"
	endif
	Notebook $PlyName text=Str
end
	
static function oDefaultPlyInfo(PlyName)
	string PlyName
	string un = "un=jbmiller&\r"
	string key = "key=q54syzx270&\r"
	//string platform = "platform=Igor,version=0.0&\r"
	string platform = "platform=Igor&\r"
	Notebook $PlyName text=un+key+platform
end	
	

static function/s Strip(s_value)
	string s_value
	//String carriage returns.
	//Should later figure out how to "grep" or othwise remove spaces preceeding the CR
	return ReplaceString("\r", s_value, "")
end

function/s CMD2Plotly(nb)
	string nb
	Notebook $nb getData=2
	string s_Post = Strip (s_value)
//	print s_post
//	print s_value
//	saveexperiment
	easyHTTP /Post=s_post "http://plot.ly/clientresp"
	print s_Gethttp
	return s_gethttp
end
	
static function/s pplot([origin,filename,fileopt])
	string origin 
	string filename
	string fileopt
	
	string un = "jbmiller"
	string key = "q54syzx270"
	string platform = "Igor"
	string kwArgs = "\""
	
	return un+"&"+key+"&"+origin+"&"+platform+"&"
end

static function ExtractRGB(rgbR,rgbG,rgbB,key,graph)
	variable &rgbR,&rgbG,&rgbB
	string key
	string graph
	string info
	variable index
	string mac = WinRecreation(graph,1)
	index=strsearch(mac,key,0)
	if (index<-1)
		print"Note, did not find the key"
		return 0
	else
		print "return",index,strsearch(mac,"\r",index)
	endif
end
a
