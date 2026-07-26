String formatLocationSummary({
  required double latitude,
  required double longitude,
  required String displayName,
}) {
  return '$displayName • $latitude, $longitude';
}

bool isWithinPakistanBounds(double latitude, double longitude) {
  const minLat = 23.0;
  const maxLat = 37.0;
  const minLon = 60.0;
  const maxLon = 77.0;

  return latitude >= minLat &&
      latitude <= maxLat &&
      longitude >= minLon &&
      longitude <= maxLon;
}
