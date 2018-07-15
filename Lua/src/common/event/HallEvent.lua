
HallEvent = {}
HallEvent.AVATAR_UPLOAD_SUCCESS = "AVATAR_UPLOAD_SUCCESS"
HallEvent.AVATAR_DOWNLOAD_URL_SUCCESS = "AVATAR_DOWNLOAD_URL_SUCCESS"

cc(HallEvent):addComponent("components.behavior.EventProtocol"):exportMethods()

