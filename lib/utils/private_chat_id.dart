String getPrivateChatId(String userId, String otherUserId) {
  if (userId.compareTo(otherUserId) < 0) {
    return '$userId-$otherUserId';
  } else {
    return '$otherUserId-$userId';
  }
}

List<String> getUserIdsFromPrivateChatId(String chatId) {
  // check if chatId is valid
  if (!chatId.contains('-')) {
    throw ArgumentError('Invalid chatId: $chatId');
  }

  return chatId.split('-');
}
