//
/*
	Shared Notifications
	Smart Like My Shoe
	3/3/2018
*/

local notify = {};
local netMsg = "smart_spawn_notify";

if (SERVER) then 

	/*
		Pooled strings 
	*/
	util.AddNetworkString(netMsg);

	/*
		Sends a net message to the client 
	*/
	function notify:NotifyPlayer(ply, message, duration)
	
		net.Start(netMsg);
		
			net.WriteString(message);
			net.WriteUInt(duration, 32);
		net.Send(ply);
	end

else // CLIENT 

	local smartDerma = include("cl_derma.lua");

	notify.activeNotifications = {};

	function notify:GenerateNotification(text, duration)
		
		local index = 1;
		for i = 1, 30 do 
			if (self.activeNotifications[i] == nil) then 
				self.activeNotifications[i] = true;
				index = i;
				break;
			end 
		end 

		smartDerma:Notification(text, duration, index);
		
		timer.Simple(duration, function()
			if (self.activeNotifications[index]) then 
				self.activeNotifications[index] = nil;
			end
		end);
	end 
	
	function notify.ReceiveNotification(len)
		notify:GenerateNotification(net.ReadString(), net.ReadUInt(32));
	end 
	net.Receive(netMsg, notify.ReceiveNotification);
end

return notify;