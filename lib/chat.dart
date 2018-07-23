class Chat {
  Chat({
    this.messages,
    this.myName,
    this.sheName,
    this.myPhone,
    this.shePhone,
    this.shePortrait,
    this.myPortrait,
    this.sessions,
    this.msgs,
  });
  final String messages;
  final String myName;
  final String sheName;
  final String myPhone;
  final String shePhone;
  final String shePortrait;
  final String myPortrait;
  final List<Map> sessions;
  final List<Map> msgs;

}