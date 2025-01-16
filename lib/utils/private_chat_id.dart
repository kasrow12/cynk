String getPrivateChatId(String userId, String otherUserId) {
  if (userId.compareTo(otherUserId) < 0) {
    return '$userId-$otherUserId';
  } else {
    return '$otherUserId-$userId';
  }
}
