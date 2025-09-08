import { useDynamicConnector } from "@/contexts/starknet";
import { processGameEvent } from "@/utils/events";
import { num } from "starknet";

export const useGameEvents = () => {
  const { currentNetworkConfig } = useDynamicConnector();

  const getGameEvents = async (gameId: number) => {
    try {
      let url = `${currentNetworkConfig.toriiUrl}/sql?query=
      SELECT data
        FROM "event_messages_historical"
        WHERE keys = "${num.toHex(gameId)}/"
        LIMIT 10000`

      const sql = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json"
        }
      })

      let data = await sql.json()
      return data.map((event: any) => processGameEvent(JSON.parse(event.data)))
    } catch (error) {
      return [];
    }
  }

  return {
    getGameEvents,
  };
};
