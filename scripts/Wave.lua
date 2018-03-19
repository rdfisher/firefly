Wave = {
  sender = {},
  recipients = {},
  messages = {}
}

function Wave:new(sender)
  local o = {}
  o.last_message = ""
  o.sender = sender
  setmetatable(o, self)
  self.__index = self
  return o
end

function Wave:registerListener(ship)
  table.insert(self.recipients, ship)
end

function Wave:stupidLua(a, b)
  if string.len(a) ~= string.len(b) then
    return false
  end

  if string.find(a, b) == nil then
    return false
  end
  return true
end

function Wave:sameAsLastMessage(message)
  -- return false
  if self:stupidLua(self.last_message, message) then
    return true
  end
  self.last_message = message
  return false
end

function Wave:message(message)
  -- Lets not spam players with messages
  if self.messages[message] == true then
    return
  end
  self.messages[message] = true
  for i, recipient in ipairs(self.recipients) do
    self.sender:sendCommsMessage(recipient, message)
  end
end

function Wave:getAccumulatedMessages()
  local messages = {}
  for message, _ in ipairs(self.messages) do
    table.insert(output, message)
  end
  self.messages = {}
  return messages
end