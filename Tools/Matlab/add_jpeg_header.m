function jpeg = add_jpeg_header(mjpeg)

  JPEGHuffmanTable = [0,... 
    0,   1,   5,   1,   1,   1,   1,   1,   1,   0,...
    0,   0,   0,   0,   0,   0,...
    0,   1,   2,   3,   4,   5,   6,   7,   8,   9,...
   10,  11,...
    1,...
    0,   3,   1,   1,   1,   1,   1,   1,   1,   1,...
    1,   0,   0,   0,   0,   0,...
    0,   1,   2,   3,   4,   5,   6,   7,   8,   9,...
   10,  11,...
   16,...
    0,   2,   1,   3,   3,   2,   4,   3,   5,   5,...
    4,   4,   0,   0,   1, 125,...
    1,   2,   3,   0,   4,  17,   5,  18,  33,  49,...
   65,   6,  19,  81,  97,   7,  34, 113,  20,  50,...
  129, 145, 161,   8,  35,  66, 177, 193,  21,  82,...
  209, 240,  36,  51,  98, 114, 130,   9,  10,  22,...
   23,  24,  25,  26,  37,  38,  39,  40,  41,  42,...
   52,  53,  54,  55,  56,  57,  58,  67,  68,  69,...
   70,  71,  72,  73,  74,  83,  84,  85,  86,  87,...
   88,  89,  90,  99, 100, 101, 102, 103, 104, 105,...
  106, 115, 116, 117, 118, 119, 120, 121, 122, 131,...
  132, 133, 134, 135, 136, 137, 138, 146, 147, 148,...
  149, 150, 151, 152, 153, 154, 162, 163, 164, 165,...
  166, 167, 168, 169, 170, 178, 179, 180, 181, 182,...
  183, 184, 185, 186, 194, 195, 196, 197, 198, 199,...
  200, 201, 202, 210, 211, 212, 213, 214, 215, 216,...
  217, 218, 225, 226, 227, 228, 229, 230, 231, 232,...
  233, 234, 241, 242, 243, 244, 245, 246, 247, 248,...
  249, 250,...
   17,...
    0,   2,   1,   2,   4,   4,   3,   4,   7,   5,...
    4,   4,   0,   1,   2, 119,...
    0,   1,   2,   3,  17,   4,   5,  33,  49,   6,...
   18,  65,  81,   7,  97, 113,  19,  34,  50, 129,...
    8,  20,  66, 145, 161, 177, 193,   9,  35,  51,...
   82, 240,  21,  98, 114, 209,  10,  22,  36,  52,...
  225,  37, 241,  23,  24,  25,  26,  38,  39,  40,...
   41,  42,  53,  54,  55,  56,  57,  58,  67,  68,...
   69,  70,  71,  72,  73,  74,  83,  84,  85,  86,...
   87,  88,  89,  90,  99, 100, 101, 102, 103, 104,...
  105, 106, 115, 116, 117, 118, 119, 120, 121, 122,...
  130, 131, 132, 133, 134, 135, 136, 137, 138, 146,...
  147, 148, 149, 150, 151, 152, 153, 154, 162, 163,...
  164, 165, 166, 167, 168, 169, 170, 178, 179, 180,...
  181, 182, 183, 184, 185, 186, 194, 195, 196, 197,...
  198, 199, 200, 201, 202, 210, 211, 212, 213, 214,...
  215, 216, 217, 218, 226, 227, 228, 229, 230, 231,...
  232, 233, 234, 242, 243, 244, 245, 246, 247, 248,...
  249, 250];

  Pjpg = [];
  Pimg = mjpeg;
  % JFIF header
  JpgFileh = [255, 216,          ... % SOI
              255, 224,          ... % APP0
                0,  16,          ... % length
               74, 70, 73, 70, 0,... % JFIF
                1, 2,            ... % VERS
                0,               ... % density
                0, 120,          ... % xdensity
                0, 120,          ... % ydensity
                0,               ... % WTN
                0];                  % HTN

  Pjpg = [Pjpg; JpgFileh];
  % calculate MJPEG header size
	MJpegHeaderSize = double(mjpeg(5) * 256 + mjpeg(6) + 4); % length + SOI+APP0
  % remove MJPEG header
  Pimg = Pimg(MJpegHeaderSize + 1 : end);
  % find frame marker (FFC0)
  FrameMarker = [255, 192];
  for i = 1 : size(Pimg, 1)
    if (Pimg(i) == FrameMarker(1)) & (Pimg(i + 1) == FrameMarker(2))
      break;
    end
  end
  % add Quantization tables and everything else
  Pjpg = [Pjpg, Pimg(1:i-1)'];
  % remove everything before frame marker
  Pimg = Pimg(i : end);

  % add huffman table with marker and length (0x01a2)
  hufmark = [255, 196, 1, 162];
  Pjpg = [Pjpg, hufmark];

  % add huffman table
  Pjpg = [Pjpg, JPEGHuffmanTable];
  % copy frame data
  Pjpg = [Pjpg, Pimg'];

  % convert to uint8
  jpeg = uint8(Pjpg);

end