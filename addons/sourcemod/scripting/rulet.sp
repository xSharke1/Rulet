#include <sourcemod>
#include <store>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Rulet", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

ConVar min_bahis = null, max_bahis = null;
int Bahis[65][2];
char History[9][16];
int Bahisler[3];


public void OnPluginStart()
{
	if (FindConVar("mp_round_restart_delay").IntValue < 3)
	{
		SetConVarInt(FindConVar("mp_round_restart_delay"), 3, true, false);
	}
	min_bahis = CreateConVar("sm_rulet_min_bahis", "50", "En az rulette kaç kredi oynansın", 0, true, 1.0);
	max_bahis = CreateConVar("sm_rulet_max_bahis", "150", "En fazla rulette kaç kredi oynansın", 0, true, 1.0);
	RegConsoleCmd("sm_rulet", Command_Rulet, "");
	HookEvent("round_end", RoundEnd);
	AutoExecConfig(true, "ByDexter", "Rulet");
	for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
	{
		OnClientPostAdminCheck(i);
	}
}

public void OnMapStart()
{
	for (int i = 0; i < 9; i++)
	{
		History[i] = "X";
	}
	for (int i = 0; i < 3; i++)
	{
		Bahisler[i] = 0;
	}
}

public void OnClientPostAdminCheck(int client)
{
	Bahis[client][0] = 0;
	Bahis[client][1] = 0;
}

public Action Command_Rulet(int client, int args)
{
	bool Oynat = true;
	if (Bahis[client][1] > 0)
	{
		Oynat = false;
	}
	
	Menu menu = new Menu(Menu_callback);
	
	if (Oynat)
	{
		char arg1[32];
		GetCmdArg(1, arg1, 32);
		
		int bahis = StringToInt(arg1);
		int kredi = Store_GetClientCredits(client);
		
		if (bahis < min_bahis.IntValue || bahis > max_bahis.IntValue)
		{
			ReplyToCommand(client, "[SM] Rulete en az %d, en fazla %d oynayabilirsin.", min_bahis.IntValue, max_bahis.IntValue);
			return Plugin_Handled;
		}
		
		if (kredi < bahis)
		{
			ReplyToCommand(client, "[SM] Bu kadar kredin bulunmuyor, kredin: %d", kredi);
			return Plugin_Handled;
		}
		
		Bahis[client][0] = bahis;
		
		menu.SetTitle("ByDexter ★ Rulet\nBahisler: K: %d S: %d Y: %d\nBahisin: %d\nGeçmiş: %s - %s - %s - %s - %s - %s - %s - %s - %s\n ", bahis, Bahisler[0], Bahisler[1], Bahisler[2], History[8], History[7], History[6], History[5], History[4], History[3], History[2], History[1], History[0]);
		menu.AddItem("1", "Kırmızı (2x)");
		menu.AddItem("2", "Siyah (2x)");
		menu.AddItem("3", "Yeşil (7x)");
	}
	else
	{
		menu.SetTitle("ByDexter ★ Bu tur rulet oynamışsın\nBahisler: K: %d S: %d Y: %d\nGeçmiş: %s - %s - %s - %s - %s - %s - %s - %s - %s\n ", Bahisler[0], Bahisler[1], Bahisler[2], History[8], History[7], History[6], History[5], History[4], History[3], History[2], History[1], History[0]);
		menu.AddItem("1", "Kırmızı (2x)", ITEMDRAW_DISABLED);
		menu.AddItem("2", "Siyah (2x)", ITEMDRAW_DISABLED);
		menu.AddItem("3", "Yeşil (7x)", ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 10);
	return Plugin_Handled;
}

public int Menu_callback(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu.GetItem(position, Item, 4);
		int item = StringToInt(Item);
		
		int bahis = Bahis[client][0];
		int kredi = Store_GetClientCredits(client);
		if (kredi >= bahis)
		{
			Bahis[client][1] = item;
			if (item == 1)
			{
				PrintToChat(client, "[SM] \x07Kırmızı \x01renge %d kredi bahis oynadın.", bahis);
			}
			else if (item == 2)
			{
				PrintToChat(client, "[SM] \x08Siyah \x01renge %d kredi bahis oynadın.", bahis);
			}
			else if (item == 3)
			{
				PrintToChat(client, "[SM] \x05Yeşil \x01renge %d kredi bahis oynadın.", bahis);
			}
			Store_SetClientCredits(client, Store_GetClientCredits(client) - bahis);
			Bahisler[item - 1]++;
		}
		else
		{
			ReplyToCommand(client, "[SM] Bu kadar kredin bulunmuyor, kredin: %d", kredi);
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action RoundEnd(Event event, const char[] name, bool dB)
{
	for (int i = 0; i < 3; i++)
	{
		Bahisler[i] = 0;
	}
	int Renk = GetRandomInt(0, 100);
	if (Renk >= 97)
	{
		PrintToChatAll("[SM] Rulette \x05Yeşil \x01renk çıktı.");
		for (int i = 0; i != 8; i++)
		{
			History[i] = History[i + 1];
		}
		for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
		{
			if (Bahis[i][1] == 3)
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + Bahis[i][0] * 7);
				PrintToChat(i, "[SM] Ruleti doğru bildin \x06%d\x01 kredi kazandın", Bahis[i][0] * 7);
			}
			Bahis[i][0] = 0;
			Bahis[i][1] = 0;
		}
		History[8] = "Y";
	}
	else if (Renk % 2 == 0)
	{
		PrintToChatAll("[SM] Rulette \x07Kırmızı \x01renk çıktı.");
		for (int i = 0; i < 9; i++)
		{
			History[i] = History[i + 1];
		}
		for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
		{
			if (Bahis[i][1] == 1)
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + Bahis[i][0] * 2);
				PrintToChat(i, "[SM] Ruleti doğru bildin \x06%d\x01 kredi kazandın", Bahis[i][0] * 2);
			}
			Bahis[i][0] = 0;
			Bahis[i][1] = 0;
		}
		History[8] = "K";
	}
	else
	{
		PrintToChatAll("[SM] Rulette \x08Siyah \x01renk çıktı.");
		for (int i = 0; i < 9; i++)
		{
			History[i] = History[i + 1];
		}
		for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
		{
			if (Bahis[i][1] == 2)
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + Bahis[i][0] * 2);
				PrintToChat(i, "[SM] Ruleti doğru bildin \x06%d\x01 kredi kazandın", Bahis[i][0] * 2);
			}
			Bahis[i][0] = 0;
			Bahis[i][1] = 0;
		}
		History[8] = "S";
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 