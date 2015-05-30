/* --- --------------------------------------------------------------------------------
    @: Socket communications, gm_bromsock
    @: http://facepunch.com/showthread.php?t=1393640
--- */

require("bromsock")

/* --- --------------------------------------------------------------------------------
    @: BromSock, by Rusketh
    @: Server to Server Communications.
    @: Example usage:
--- */

  --[[
        BromNet.Receive("Example", function(senderIP, snederPort, Message)
          local str = BromNet.ReadString()
          local nbr = BromNet.ReadShort()
          print(str, nbr)
        end)
        
        BromNet.Start("Example")
          BromNet.WriteString("Hello World")
          BromNet.WriteShort(666)
        BronNet.Send(ip, port)

        To set listen port use 'sv_socket <port>' in server.cgf
  ]]--


/* --- --------------------------------------------------------------------------------
    @: BromNet - Core
   --- */

local pkt_write, pkt_read

BromNet = {
  Hooks = {},
  Servers = {},
  Connected = false,

  Open = function()
    if !BromNet.Port then return end
    if BromNet.Socket then BromNet.Socket:Close() end

    local Socket = BromSock()
    BromNet.Socket = Socket

    if !Socket:Listen(BromNet.Port) then
      MsgN("BtomNet - Could not listen on port ", BromNet.Port, ".")
    else
      MsgN("BtomNet - listening on port ", BromNet.Port, ".")
    end

    Socket:SetCallbackAccept(BromNet.AcceptConnection)
    Socket:Accept()
  end,

  AcceptConnection = function(socket, client)
    client:SetCallbackReceive(BromNet.ReceiveFromclient)
    client:SetTimeout(1000)
    client:Receive()
    BromNet.Socket:Accept()
  end,


  Receive = function(name, func)
    BromNet.Hooks[name] = func
  end,

  ReceiveFromclient = function(client, packet)
    local name = packet:ReadString()
    local func = BromNet.Hooks[name]

    if func then
      pkt_read = packet
      
      local _, e = pcall(func, client:GetIP(), client:GetPort(), name)

      if !_ then
        BromNet.Hooks[name] = nil
        MsgN("BromNet - Error with message ", name, ".")
        MsgN(e)
      end

      pkt_read = nil
    else
        MsgN("BromNet - Unhandled message ", name, ".")
    end

    client:Close()
    packet:Clear()
    packet = nil
  end,

  Start = function(name)
    pkt_write = BromPacket()
    pkt_write:WriteString(name)
    return pkt_write
  end,

  Send = function(ip, port)
    local packet = pkt_write
    local socket = BromSock(BROMSOCK_TCP)

    socket:SetCallbackConnect(function()
      socket:Send(packet)
      socket:Close()
      packet:Clear()
      socket = nil
      packet = nil
    end)

    socket:Connect(ip, port)
    pkt_write = nil
  end,

  Broadcast = function(ip, port, ...)
    local pkt = pkt_write
    local sends, total = 0, 0

    for _, port in pairs({port, ...}) do
      local socket = BromSock(BROMSOCK_TCP)

      socket:SetCallbackConnect(function()
        local packet = pkt:Copy()
        socket:Send(packet)
        socket:Close()
        socket = nil
        packet = nil

        sends = sends + 1

        if sends == total then
          pkt:Clear()
          pkt = nil
        end
      end)

      socket:Connect(ip, port)
      total = total + 1
    end

    pkt_write = nil
  end,

  /************************************************************************************/

  WriteString = function(str)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteString(str)
  end,

  ReadString = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadString()
  end,

  WriteData = function(str)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteStringRaw(str)
  end,

  ReadData = function(len)
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadString(len)
  end,

  WriteBool = function(bool)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteByte(bool and 1 or 0)
  end,

  ReadBool = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadByte() == 1
  end,

  WriteByte = function(byte)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteByte(byte)
  end,

  ReadByte = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadByte()
  end,

  WriteShort = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteShort(num)
  end,

  ReadShort = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadShort()
  end,

  WriteUShort = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteUShort(num)
  end,

  ReadUShort = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadUShort()
  end,

  WriteLong = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteLong(num)
  end,

  ReadLong = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadLong()
  end,

  WriteULong = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteULong(num)
  end,

  ReadULong = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadULong()
  end,

  WriteDouble = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteDouble(num)
  end,

  ReadDouble = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadDouble()
  end,

  WriteInt = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteInt(num)
  end,

  ReadInt = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadInt()
  end,

  WriteUInt = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteUInt(num)
  end,

  ReadUInt = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadUInt()
  end,

  WriteFloat = function(num)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteFloat(num)
  end,

  ReadFloat = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:ReadFloat()
  end,

  /************************************************************************************/

  WriteVector = function(vec)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteFloat(vec.x)
    pkt_write:WriteFloat(vec.y)
    pkt_write:WriteFloat(vec.z)
  end,

  ReadVector = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return Vector(pkt_read:ReadFloat(), pkt_read:ReadFloat(), pkt_read:ReadFloat())
  end,

  WriteAngle = function(ang)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteFloat(ang.p)
    pkt_write:WriteFloat(ang.y)
    pkt_write:WriteFloat(ang.r)
  end,

  ReadAngle = function()
      if !pkt_read then error("pkt_read does not exist.", 0) end
      return Angle(pkt_read:ReadFloat(), pkt_read:ReadFloat(), pkt_read:ReadFloat())
  end,

  WriteColor = function(col)
    if !pkt_write then error("pkt_write does not exist.", 0) end
    pkt_write:WriteFloat(col.r)
    pkt_write:WriteFloat(col.g)
    pkt_write:WriteFloat(col.b)
    pkt_write:WriteFloat(col.a)
  end,

  ReadColor = function()
      if !pkt_read then error("pkt_read does not exist.", 0) end
      return Color(pkt_read:ReadFloat(), pkt_read:ReadFloat(), pkt_read:ReadFloat(), pkt_read:ReadFloat())
  end,

  /************************************************************************************/

  GetWritePacketPos = function()
    if !pkt_write then error("pkt_write does not exist.", 0) end
    return pkt_write:InPos()
  end,

  GetReadPacketPos = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:OutPos()
  end,

  GetWritePacketSize = function()
    if !pkt_write then error("pkt_write does not exist.", 0) end
    return pkt_write:InSize()
  end,

  GetReadPacketSize = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:OutSize()
  end,

  ClearWritePacket = function()
    if !pkt_write then error("pkt_write does not exist.", 0) end
    return pkt_write:Clear()
  end,

  ClearReadPacket = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read:Clear()
  end,

  GetWritePacket = function()
    if !pkt_write then error("pkt_write does not exist.", 0) end
    return pkt_write
  end,

  GetReadPacket = function()
    if !pkt_read then error("pkt_read does not exist.", 0) end
    return pkt_read
  end,
}

concommand.Add("sv_socket",function(ply, _, args)
  if !IsValid(ply) then
    BromNet.Port = tonumber(args[1])
    BromNet.Open()
  end
end)
