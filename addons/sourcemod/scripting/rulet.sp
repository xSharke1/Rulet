#include <sourcemod>
#include <emitsoundany>
#include <store>

#pragma semicolon 1
#pragma newdecls required

ConVar Yesilx = null, Kirmizix = null, Siyahx = null, Max = null, Min = null, Mod = null, Timeri = null;
int YY = 0, KY = 0, SY = 0;
char G1[20] = "X", G2[20] = "X", G3[20] = "X", G4[20] = "X", G5[20] = "X", G6[20] = "X", G7[20] = "X", G8[20] = "X";
int Rulet[65] =  { 0, ... };
bool YG[65] =  { false, ... }, KG[65] =  { false, ... }, SG[65] =  { false, ... }, RG[65] =  { false, ... };
bool Block = false;
Handle Zamanlayici = null;

public Plugin myinfo = 
{
	name = "Rulet", 
	author = "ByDexter", 
	description = "", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

#define LoopClients(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1))

public void OnPluginStart()
{
	if (GetConVarInt(FindConVar("mp_round_restart_delay")) < 5)
		SetCvar("mp_round_restart_delay", 6);
	
	Yesilx = CreateConVar("sm_rulet_yesilkati", "14", "Yeşil tutturan oyuncu kaç kat kredi kazansın", 0, true, 1.0, false);
	Kirmizix = CreateConVar("sm_rulet_kirmizikati", "2", "Kırmızı tutturan oyuncu kaç kat kredi kazansın", 0, true, 1.0, false);
	Siyahx = CreateConVar("sm_rulet_siyahkati", "2", "Siyah tutturan oyuncu kaç kat kredi kazansın", 0, true, 1.0, false);
	Max = CreateConVar("sm_rulet_max", "1000", "Rulete en fazla girelecek", 0, true, 1.0, false);
	Min = CreateConVar("sm_rulet_min", "100", "Rulete en az girelecek", 0, true, 1.0, false);
	Timeri = CreateConVar("sm_rulet_saniye", "120.0", "Eğer rulet mod 1 ise kaç saniye arayla açıklanısn", 0, true, 11.0, false);
	Mod = CreateConVar("sm_rulet_mod", "0", "Rulet Mod [ 0 = Tur Sonu Açıklansın | 1 = X saniye Sonra Açıklansın ]", 0, true, 0.0, true, 1.0);
	Timeri.AddChangeHook(TimerHook);
	Mod.AddChangeHook(ModHook);
	if (Mod.BoolValue)
	{
		TimerKapat();
		Zamanlayici = CreateTimer(Timeri.FloatValue - 10.0, Duyur, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		TimerKapat();
	}
	RegConsoleCmd("sm_rulet", Command_Rulet);
	HookEvent("round_end", RoundEnd);
	HookEvent("round_start", RoundStart);
	AutoExecConfig(true, "Rulet", "ByDexter");
}

public void OnMapStart()
{
	PrecacheSoundAny("misc/store_roulette/winner.mp3");
	AddFileToDownloadsTable("sound/misc/store_roulette/winner.mp3");
}

public void TimerHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (Mod.BoolValue)
	{
		TimerKapat();
		Zamanlayici = CreateTimer(Timeri.FloatValue - 10.0, Duyur, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void ModHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (Mod.BoolValue)
	{
		TimerKapat();
		Zamanlayici = CreateTimer(Timeri.FloatValue - 10.0, Duyur, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		TimerKapat();
	}
}

public Action Duyur(Handle timer)
{
	PrintToChatAll("[SM] \x10Ruletin açıklanmasına son \x0410 Saniye");
	Zamanlayici = null;
	Zamanlayici = CreateTimer(10.0, RuletAcikla, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public Action RuletAcikla(Handle timer)
{
	Zamanlayici = null;
	Block = true;
	Log("--------------------- Rulet Açıklanacak ---------------------");
	PrintToChatAll("[SM] \x04Rulet birazdan açıklanacak.");
	CreateTimer(2.0, Delay, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	if (RG[client])
	{
		Log("%N Ruleti unuttu %d Kredi kaybetti.", client, Rulet[client]);
		if (YG[client])
			YY--;
		else if (KG[client])
			KY--;
		else if (SG[client])
			SY--;
	}
}

public Action Command_Rulet(int client, int args)
{
	if (Block)
	{
		ReplyToCommand(client, "[SM] \x02Rulet şuan kapalı.");
		return Plugin_Handled;
	}
	if (args < 1)
	{
		char Item[128];
		Panel panel = new Panel();
		panel.SetTitle("Rulet");
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		Format(Item, 128, "Geçmiş: > %s < - %s - %s - %s - %s - %s - %s - %s", G1, G2, G3, G4, G5, G6, G7, G8);
		panel.DrawText(Item);
		Format(Item, 128, "Oyuncular: Y %d - K %d - S %d", YY, KY, SY);
		panel.DrawText(Item);
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		Format(Item, 128, "➔ Yeşil(%dx)", Yesilx.IntValue);
		panel.DrawItem(Item, ITEMDRAW_DISABLED);
		Format(Item, 128, "➔ Kırmızı(%dx)", Kirmizix.IntValue);
		panel.DrawItem(Item, ITEMDRAW_DISABLED);
		Format(Item, 128, "➔ Siyah(%dx)\n ", Siyahx.IntValue);
		panel.DrawItem(Item, ITEMDRAW_DISABLED);
		panel.DrawItem("➔ Kapat");
		panel.Send(client, Panel_CallBack2, 20);
		delete panel;
		return Plugin_Handled;
	}
	if (!RG[client])
	{
		char Arg1[128];
		GetCmdArg(1, Arg1, 128);
		int Yatirilan = StringToInt(Arg1);
		if (Yatirilan < Min.IntValue || Yatirilan > Max.IntValue)
		{
			ReplyToCommand(client, "[SM] Kullanım: sm_rulet <%d-%d>", Min.IntValue, Max.IntValue);
			return Plugin_Handled;
		}
		int Kredi = Store_GetClientCredits(client);
		if (Kredi < Yatirilan)
		{
			ReplyToCommand(client, "[SM] \x10Yeterli kredin yok, \x04mevcut kredin: %d", Kredi);
			return Plugin_Handled;
		}
		Rulet[client] = Yatirilan;
		char Item[128];
		Panel panel = new Panel();
		Format(Item, 128, "Rulet - %d Kredi", Yatirilan);
		panel.SetTitle(Item);
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		Format(Item, 128, "Geçmiş: > %s < - %s - %s - %s - %s - %s - %s - %s", G1, G2, G3, G4, G5, G6, G7, G8);
		panel.DrawText(Item);
		Format(Item, 128, "Oyuncular: Y %d - K %d - S %d", YY, KY, SY);
		panel.DrawText(Item);
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		Format(Item, 128, "➔ Yeşil(%dx)", Yesilx.IntValue);
		panel.DrawItem(Item);
		Format(Item, 128, "➔ Kırmızı(%dx)", Kirmizix.IntValue);
		panel.DrawItem(Item);
		Format(Item, 128, "➔ Siyah(%dx)\n ", Siyahx.IntValue);
		panel.DrawItem(Item);
		panel.DrawItem("➔ Kapat");
		panel.Send(client, Panel_CallBack, 20);
		delete panel;
		return Plugin_Handled;
	}
	else
	{
		char Item[128];
		Panel panel = new Panel();
		panel.SetTitle("Rulet");
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		Format(Item, 128, "Geçmiş: > %s < - %s - %s - %s - %s - %s - %s - %s", G1, G2, G3, G4, G5, G6, G7, G8);
		panel.DrawText(Item);
		Format(Item, 128, "Oyuncular: Y %d - K %d - S %d", YY, KY, SY);
		panel.DrawText(Item);
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		Format(Item, 128, "➔ Yeşil(%dx)", Yesilx.IntValue);
		panel.DrawItem(Item, ITEMDRAW_DISABLED);
		Format(Item, 128, "➔ Kırmızı(%dx)", Kirmizix.IntValue);
		panel.DrawItem(Item, ITEMDRAW_DISABLED);
		Format(Item, 128, "➔ Siyah(%dx)\n ", Siyahx.IntValue);
		panel.DrawItem(Item, ITEMDRAW_DISABLED);
		panel.DrawItem("➔ Kapat");
		panel.Send(client, Panel_CallBack2, 20);
		delete panel;
		return Plugin_Handled;
	}
}

public int Panel_CallBack(Menu panel, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (item != 4)
			{
				if (!Block)
				{
					int Kredi = Store_GetClientCredits(client);
					if (Kredi > Rulet[client])
					{
						RG[client] = true;
						Store_SetClientCredits(client, Store_GetClientCredits(client) - Rulet[client]);
						if (item == 1)
						{
							Log("%N Yeşile %d Kredi girdi.", client, Rulet[client]);
							PrintToChat(client, "[SM] \x04Yeşil'e \x0E%d Kredi \x01yatırdın.", Rulet[client]);
							YG[client] = true;
							YY++;
						}
						else if (item == 2)
						{
							Log("%N Kırmızıya %d Kredi girdi.", client, Rulet[client]);
							PrintToChat(client, "[SM] \x07Kırmızı'ya \x0E%d Kredi \x01yatırdın.", Rulet[client]);
							KG[client] = true;
							KY++;
						}
						else if (item == 3)
						{
							Log("%N Siyaha %d Kredi girdi.", client, Rulet[client]);
							PrintToChat(client, "[SM] \x08Siyah'a \x0E%d Kredi \x01yatırdın.", Rulet[client]);
							SG[client] = true;
							SY++;
						}
					}
					else
					{
						PrintToChat(client, "[SM] \x10Yeterli kredin yok, \x04mevcut kredin: %d", Kredi);
					}
				}
				else
				{
					PrintToChat(client, "[SM] \x02Rulet şuan kapalı.");
				}
				
			}
		}
	}
}

public int Panel_CallBack2(Menu panel, MenuAction action, int client, int item)
{
}

public Action RoundEnd(Event event, const char[] name, bool db)
{
	if (!Mod.BoolValue)
	{
		Block = true;
		Log("--------------------- Rulet Açıklanacak ---------------------");
		PrintToChatAll("[SM] \x04Rulet birazdan açıklanacak.");
		CreateTimer(2.0, Delay, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Delay(Handle timer)
{
	int Cikan = GetRandomInt(1, 100);
	if (Cikan <= 2)
	{
		Log("Rulet Yeşil Çıktı.");
		G8 = G7;
		G7 = G6;
		G6 = G5;
		G5 = G4;
		G4 = G3;
		G3 = G2;
		G2 = G1;
		G1 = "Y";
		PrintToChatAll("[SM] \x10Rulette Kazanan Renk: \x04Yeşil");
		PrintHintTextToAll("Rulette Kazanan Renk Yeşil");
		LoopClients(i)
		{
			if (RG[i])
			{
				if (YG[i])
				{
					Log("%N Yeşil katladı %d kredi kazandı", i, Rulet[i] * Yesilx.IntValue);
					Store_SetClientCredits(i, Store_GetClientCredits(i) + Rulet[i] * Yesilx.IntValue);
					EmitSoundToClientAny(i, "misc/store_roulette/winner.mp3", SOUND_FROM_PLAYER, 1, 100);
					PrintToChat(i, "[SM] \x04Yeşilden \x0E%d Kredi \x01kazandın.", Rulet[i] * Yesilx.IntValue);
				}
				else
				{
					Log("%N Yeşile girmediği için %d kredi kaybetti", i, Rulet[i]);
					PrintToChat(i, "[SM] \x0E%d Kredi \x07Kaybettin.", Rulet[i]);
				}
			}
		}
	}
	else if (Cikan <= 51)
	{
		Log("Rulet Kırmızı Çıktı.");
		G8 = G7;
		G7 = G6;
		G6 = G5;
		G5 = G4;
		G4 = G3;
		G3 = G2;
		G2 = G1;
		G1 = "K";
		PrintToChatAll("[SM] \x10Rulette Kazanan Renk: \x07Kırmızı");
		PrintHintTextToAll("Rulette Kazanan Renk Kırmızı");
		LoopClients(i)
		{
			if (RG[i])
			{
				if (KG[i])
				{
					Log("%N Kırmızı katladı %d kredi kazandı", i, Rulet[i] * Kirmizix.IntValue);
					Store_SetClientCredits(i, Store_GetClientCredits(i) + Rulet[i] * Kirmizix.IntValue);
					EmitSoundToClientAny(i, "misc/store_roulette/winner.mp3", SOUND_FROM_PLAYER, 1, 100);
					PrintToChat(i, "[SM] \x07Kırmızıdan \x0E%d Kredi \x01kazandın.", Rulet[i] * Kirmizix.IntValue);
				}
				else
				{
					Log("%N Kırmızıya girmediği için %d kredi kaybetti", i, Rulet[i]);
					PrintToChat(i, "[SM] \x0E%d Kredi \x07Kaybettin.", Rulet[i]);
				}
			}
		}
	}
	else
	{
		Log("Rulet Siyah Çıktı.");
		G8 = G7;
		G7 = G6;
		G6 = G5;
		G5 = G4;
		G4 = G3;
		G3 = G2;
		G2 = G1;
		G1 = "S";
		PrintToChatAll("[SM] \x10Rulette Kazanan Renk: \x08Siyah");
		PrintHintTextToAll("Rulette Kazanan Renk Siyah");
		LoopClients(i)
		{
			if (RG[i])
			{
				if (SG[i])
				{
					Log("%N Siyah katladı %d kredi kazandı", i, Rulet[i] * Siyahx.IntValue);
					Store_SetClientCredits(i, Store_GetClientCredits(i) + Rulet[i] * Siyahx.IntValue);
					EmitSoundToClientAny(i, "misc/store_roulette/winner.mp3", SOUND_FROM_PLAYER, 1, 100);
					PrintToChat(i, "[SM] \x08Siyahtan \x0E%d Kredi \x01kazandın.", Rulet[i] * Siyahx.IntValue);
				}
				else
				{
					Log("%N Siyah girmediği için %d kredi kaybetti", i, Rulet[i]);
					PrintToChat(i, "[SM] \x0E%d Kredi \x07Kaybettin.", Rulet[i]);
				}
			}
		}
	}
	LoopClients(i)
	{
		Rulet[i] = 0;
		YG[i] = false, KG[i] = false, SG[i] = false, RG[i] = false;
	}
	YY = 0, KY = 0, SY = 0;
	if (Mod.BoolValue)
	{
		Log("--------------------- Rulet Açıldı ---------------------");
		Block = false;
		Zamanlayici = CreateTimer(Timeri.FloatValue - 10.0, Duyur, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}

public Action RoundStart(Event event, const char[] name, bool db)
{
	if (!Mod.BoolValue)
	{
		Log("--------------------- Rulet Açıldı ---------------------");
		Block = false;
	}
}

void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

void Log(const char[] buffer, any...)
{
	char Dosya[256];
	FormatTime(Dosya, 256, "%d_%b_%Y", GetTime());
	char log[256];
	VFormat(log, 256, buffer, 2);
	Format(Dosya, 256, "addons/sourcemod/logs/rulet/%s.log", Dosya);
	LogToFileEx(Dosya, log);
}

void TimerKapat()
{
	if (Zamanlayici != null)
	{
		delete Zamanlayici;
		Zamanlayici = null;
	}
} 