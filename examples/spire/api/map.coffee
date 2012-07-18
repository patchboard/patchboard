module.exports =

  account_collection:
    paths: ["/accounts"]

  account:
    paths: ["/account/:account_id"]

  session_collection:
    paths: ["/sessions"]

  session:
    paths: ["/account/:account_id/session/:session_id"]

  channel_collection:
    paths: ["/account/:account_id/channels"]

  channel:
    paths: ["/account/:account_id/channel/:channel_id"]

  subscription_collection:
    paths: ["/account/:account_id/subscriptions"]
        
  subscription:
    paths: ["/account/:account_id/subscription/:subscription_id"]

  message:
    paths: ["/account/:account_id/channel/:channel_id/messages/:message_id"]
