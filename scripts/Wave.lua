Wave = {
  sender = {},
  recipients = {}
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

function Wave:message(message)
  for i, recipient in ipairs(self.recipients) do
    self.sender:sendCommsMessage(recipient, message)
  end
end