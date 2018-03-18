Wave = {
  sender = {},
  recipients = {},
  messages = {},
  last_message = nil
}

function Wave:new(sender)
  local o = {}
  o.sender = sender
  setmetatable(o, self)
  self.__index = self
  return o
end

function Wave:registerListener(ship)
  table.insert(self.recipients, ship)
end

function Wave:sameAsLastMessage(message)
  if self.last_message ~= nil then
    if self.last_message.callsign ~= message.callsign and self.last_message.sector ~= message.sector then
      return false
    end
  end

  self.last_message = message
  return true
end

function Wave:message(message)
  -- Lets not spam players with messages
  if self:sameAsLastMessage(message) then
    return
  end
  table.insert(self.messages, message)
  for i, recipient in ipairs(self.recipients) do
    self.sender:sendCommsMessage(recipient, message)
  end
end

function Wave:getAccumulatedMessages()
  local messages = self.messages
  self.messages = {}
  return messages
end