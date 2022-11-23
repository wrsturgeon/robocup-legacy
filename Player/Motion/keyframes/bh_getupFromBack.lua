local mot = {};
mot.servos = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22};
mot.keyframes = {
  {
    angles = vector.new({0.000, 30.000, 97.800, 13.000, 1.800, -2.100, 3.100, -0.400, -6.700, 13.100, 64.100, -4.200, 3.100, -2.600, -7.800, 16.400, 64.600, 4.600, 96.100, -17.700, -19.800, 11.300, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.200;
  },
  {
    angles = vector.new({0.000, 30.000, 97.700, 14.900, 1.600, -1.200, -4.800, 1.800, -31.900, 84.000, 41.900, 4.000, -4.800, -1.100, -36.400, 92.700, 37.500, -2.500, 96.200, -17.100, -20.200, 11.200, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.200;
  },
  {
    angles = vector.new({0.000, 30.300, 122.300, 70.300, 9.100, -90.000, 1.000, -7.900, 21.900, 96.900, -3.200, -1.100, 1.000, -7.000, 25.400, 102.700, -12.000, 1.200, 121.300, -69.700, -9.100, 90.000, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.200;
  },
  {
    angles = vector.new({-0.400, 30.300, 123.600, 8.000, 9.000, -90.000, -0.200, -8.300, 19.100, 102.100, -5.200, 0.700, -0.200, -6.500, 24.400, 107.200, -15.300, 1.400, 120.900, -12.300, -6.900, 85.300, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.200;
  },
  {
    angles = vector.new({0.000, 30.000, 117.200, 3.700, -1.900, -70.900, 6.000, 2.500, 24.000, 7.900, 64.700, -4.700, 6.000, -0.100, 25.700, 7.100, 64.900, 4.900, 122.900, -11.400, 6.500, 77.100, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.200;
  },
  {
    angles = vector.new({0.000, 30.000, 116.500, 9.400, -0.800, -78.900, 3.000, 3.500, -6.100, -7.000, 63.900, -4.300, 3.000, 4.000, -4.800, -6.900, 64.300, 4.500, 112.500, -11.300, -7.800, 78.400, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.200;
  },
  {
    angles = vector.new({0.200, 22.500, 123.400, 10.300, 18.700, -79.600, 5.300, 4.600, -48.900, -5.200, 53.000, 1.600, 5.300, 1.900, -47.600, -6.000, 53.600, 1.100, 123.100, -13.400, -23.900, 81.700, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({3.600, 29.800, 112.200, -8.600, -3.300, -15.900, -26.700, -1.600, -91.700, -1.500, -70.000, 0.400, -26.700, 0.700, -92.000, -2.000, -70.000, -2.700, 115.300, 10.700, -2.600, 15.600, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.300;
  },
  {
    angles = vector.new({3.600, 29.800, 112.200, -8.600, -3.300, -15.900, -26.700, -1.600, -91.700, -1.500, -70.000, 0.400, -26.700, 0.700, -92.000, -2.000, -70.000, -2.700, 115.300, 10.700, -2.600, 15.600, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.300;
  },
  {
    angles = vector.new({7.500, 30.000, 119.800, 7.800, -71.100, -31.400, -56.300, 15.800, -50.000, -6.900, 8.800, -12.400, -56.300, -19.000, -49.100, -6.900, 16.000, -4.700, 121.600, -0.400, 87.500, 22.200, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({6.900, 30.000, 119.900, -4.800, -85.300, -18.600, -65.000, 41.700, -80.200, 76.500, 49.300, -7.200, -65.000, -32.500, -84.000, 81.800, 47.100, 1.100, 121.600, -0.900, 87.400, 22.400, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.300;
  },
  {
    angles = vector.new({5.500, 29.400, 115.800, -7.600, -84.600, -15.900, -68.900, 11.700, -29.700, 124.600, -40.900, -18.900, -68.900, -20.300, -89.400, 48.200, 52.600, -1.000, 120.700, -39.700, 99.400, 8.200, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({5.500, 29.400, 115.800, -7.600, -84.600, -15.900, -68.900, 11.700, -29.700, 124.600, -40.900, -18.900, -68.900, -20.300, -89.400, 48.200, 52.600, -1.000, 120.700, -39.700, 99.400, 8.200, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.100;
  },
  {
    angles = vector.new({4.800, 29.600, 99.700, 21.000, -84.900, -15.000, -64.800, 4.100, -32.900, 124.600, -57.900, 10.000, -64.800, -15.000, -18.200, -5.900, 62.600, 4.000, 107.100, -20.200, 99.100, 8.800, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({5.300, 29.700, 89.600, 20.600, -84.900, -15.000, -43.500, 12.400, -55.300, 124.700, -55.800, 9.100, -43.500, 13.600, -44.000, 95.100, -15.900, 15.100, 99.000, -0.400, 99.000, 8.500, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({5.000, 29.600, 87.400, 18.900, -85.000, -14.400, -32.900, -7.400, -60.000, 124.700, -48.800, 7.500, -32.900, 8.800, -57.100, 124.600, -50.700, -8.800, 81.000, -11.000, 99.100, 7.800, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({4.900, 30.000, 82.000, 12.800, -84.100, -12.100, 0.200, -3.800, -53.300, 124.600, -69.800, 1.900, 0.200, 5.800, -52.200, 124.600, -70.000, -4.800, 75.400, -6.800, 99.200, 6.800, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.300;
  },
  {
    angles = vector.new({0.000, 30.000, 90.000, 11.500, -90.000, -11.500, 0.000, -0.000, -45.000, 71.400, -35.100, -0.000, 0.000, 0.000, -45.000, 71.400, -35.100, 0.000, 90.000, -11.500, 90.000, 11.500, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.500;
  },
  {
    angles = vector.new({0.000, 30.000, 90.000, 11.500, -90.000, -11.500, 0.000, -0.000, -45.000, 71.400, -35.100, -0.000, 0.000, 0.000, -45.000, 71.400, -35.100, 0.000, 90.000, -11.500, 90.000, 11.500, }) * math.pi / 180,
    stiffnesses = {0.300, 0.300, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, 0.900, },
    duration = 0.100;
  },
};
return mot;
