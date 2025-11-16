local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

httprequest = missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))

local HttpService = game:GetService("HttpService")

export type Author = {
	Name: string,
	IconUrl: string?,
}

export type Field = {
	Name: string,
	Value: string,
	Inline: boolean?,
}

export type Embed = {
	Title: string,
	Description: string,
	Color: number,
	Author: Author?,
	Fields: {Field},
}

export type Message = {
	Content: string,
	Username: string?,
	Embeds: {Embed},
}

local Hook = {}
Hook.__index = Hook

function Hook:CreateEmbed(title: string?, description: string?, color: number?, author: Author?, fields: {Field}?)
	return {
		Title = title or "",
		Description = description or "",
		Color = color or 0x000000,
		Author = author,
		Fields = fields or {},
	}
end

function Hook:CreateMessage(content: string?, username: string?, embeds: {Embed}?)
	local message = {
		Content = content or "",
		Embeds = embeds or {},
	}
	if username then
		message.Username = username
	end
	return message
end

function Hook:Send(webhookUrl: string, message: Message)
	local body = HttpService:JSONEncode(message)
	local options = {
		Url = webhookUrl,
		Method = "POST",
		Body = body,
		Headers = {
			["Content-Type"] = "application/json"
		}
	}
	local response = httprequest(options)
	return response
end

return Hook