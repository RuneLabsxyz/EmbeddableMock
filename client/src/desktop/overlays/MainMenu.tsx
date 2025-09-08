import { useController } from "@/contexts/controller";
import { useDynamicConnector } from "@/contexts/starknet";
import discordIcon from "@/desktop/assets/images/discord.png";
import AdventurersList from "@/desktop/components/AdventurersList";
import BeastsCollected from "@/components/BeastsCollected";
import PaymentOptionsModal from "@/components/PaymentOptionsModal";
import Settings from "@/desktop/components/Settings";
import { getMenuLeftOffset } from "@/utils/utils";
import GitHubIcon from "@mui/icons-material/GitHub";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import ShieldOutlinedIcon from "@mui/icons-material/ShieldOutlined";
import TokenIcon from "@mui/icons-material/Token";
import XIcon from "@mui/icons-material/X";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Divider from "@mui/material/Divider";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useAccount } from "@starknet-react/core";
import { AnimatePresence } from "framer-motion";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Network from "../components/Network";
import PriceIndicator from "../../components/PriceIndicator";
import WalletConnect from "../components/WalletConnect";
import StatisticsModal from "./StatisticsModal";
import MenuBookIcon from "@mui/icons-material/MenuBook";
import Leaderboard from "../components/Leaderboard";
import LeaderboardIcon from "@mui/icons-material/Leaderboard";

export default function MainMenu() {
  const navigate = useNavigate();
  const { account } = useAccount();
  const { login } = useController();
  const { currentNetworkConfig } = useDynamicConnector();
  const [showAdventurers, setShowAdventurers] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [showLeaderboard, setShowLeaderboard] = useState(false);
  const [showStats, setShowStats] = useState(false);
  const [showPaymentOptions, setShowPaymentOptions] = useState(false);
  const [left, setLeft] = useState(getMenuLeftOffset());

  useEffect(() => {
    function handleResize() {
      setLeft(getMenuLeftOffset());
    }
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  const handleStartGame = () => {
    if (currentNetworkConfig.chainId === import.meta.env.VITE_PUBLIC_CHAIN) {
      if (!account) {
        login();
        return;
      }

      setShowPaymentOptions(true);
    } else {
      navigate(`/survivor/play`);
    }
  };

  const handleShowAdventurers = () => {
    if (
      currentNetworkConfig.chainId === import.meta.env.VITE_PUBLIC_CHAIN &&
      !account
    ) {
      login();
      return;
    }

    setShowAdventurers(true);
  };

  return (
    <>
      <Box sx={{ ...styles.container, left: `${left + 32}px` }}>
        <AnimatePresence mode="wait">
          {showAdventurers && (
            <AdventurersList onBack={() => setShowAdventurers(false)} />
          )}
          {showLeaderboard && (
            <Leaderboard onBack={() => setShowLeaderboard(false)} />
          )}
          {showSettings && <Settings onBack={() => setShowSettings(false)} />}

          {!showAdventurers && !showSettings && !showLeaderboard && (
            <>
              <Box sx={styles.headerBox}>
                <Typography sx={styles.gameTitle}>LOOT SURVIVOR 2</Typography>
                <Typography color="secondary" sx={styles.modeTitle}>
                  {currentNetworkConfig.name}
                </Typography>
              </Box>

              {currentNetworkConfig.name === "Beast Mode" && <PriceIndicator />}

              <Button
                variant="outlined"
                fullWidth
                size="large"
                onClick={handleStartGame}
                sx={{
                  px: 1,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  height: "36px",
                }}
              >
                <Box sx={{ display: "flex", alignItems: "center" }}>
                  <TokenIcon sx={{ fontSize: 20, mr: 1 }} />
                  <Typography
                    sx={{
                      fontSize: "0.85rem",
                      fontWeight: 500,
                      letterSpacing: 0.5,
                      color: "#d0c98d",
                    }}
                  >
                    New Game
                  </Typography>
                </Box>
              </Button>

              <Button
                variant="outlined"
                fullWidth
                size="large"
                onClick={handleShowAdventurers}
                sx={{ pl: 1, height: "36px" }}
              >
                <ShieldOutlinedIcon sx={{ fontSize: 20, mr: 1 }} />
                <Typography
                  sx={{
                    fontSize: "0.85rem",
                    fontWeight: 500,
                    letterSpacing: 0.5,
                    color: "#d0c98d",
                  }}
                >
                  My Adventurers
                </Typography>
              </Button>

              <Divider sx={{ width: "100%", my: 0.5 }} />

              <Button
                variant="outlined"
                fullWidth
                size="large"
                onClick={() => setShowLeaderboard(true)}
                sx={{ pl: 1, height: "36px" }}
              >
                <LeaderboardIcon sx={{ fontSize: 20, mr: 1 }} />
                <Typography
                  sx={{
                    fontSize: "0.85rem",
                    fontWeight: 500,
                    letterSpacing: 0.5,
                    color: "#d0c98d",
                  }}
                >
                  Leaderboard
                </Typography>
              </Button>

              <Button
                variant="outlined"
                fullWidth
                size="large"
                onClick={() => setShowSettings(true)}
                sx={{ pl: 1, height: "36px" }}
              >
                <SettingsOutlinedIcon sx={{ fontSize: 20, mr: 1 }} />
                <Typography
                  sx={{
                    fontSize: "0.85rem",
                    color: "#d0c98d",
                    fontWeight: 500,
                    letterSpacing: 0.5,
                  }}
                >
                  Settings
                </Typography>
              </Button>

              {/* <Button
                variant="outlined"
                fullWidth
                size="large"
                onClick={() => setShowStats(true)}
                sx={{ px: 1, height: '36px' }}
                disabled={true}
              >
                <BarChartIcon sx={{ fontSize: 20, mr: 1 }} />
                <Typography sx={{ fontSize: '0.85rem', color: 'rgba(255, 255, 255, 0.3)', fontWeight: 500, letterSpacing: 0.5 }}>
                  Statistics
                </Typography>
              </Button> */}

              <Box sx={styles.bottom}>
                {currentNetworkConfig.name === "Beast Mode" && (
                  <BeastsCollected />
                )}

                <Network />
                <WalletConnect />

                <Box sx={styles.bottomRow}>
                  <Typography sx={styles.alphaVersion}>
                    Provable Games
                  </Typography>
                  <Box sx={styles.socialButtons}>
                    <IconButton
                      size="small"
                      sx={styles.socialButton}
                      onClick={() =>
                        window.open(
                          "https://docs.provable.games/lootsurvivor",
                          "_blank"
                        )
                      }
                    >
                      <MenuBookIcon sx={{ fontSize: 20 }} />
                    </IconButton>
                    <IconButton
                      size="small"
                      sx={styles.socialButton}
                      onClick={() =>
                        window.open("https://x.com/LootSurvivor", "_blank")
                      }
                    >
                      <XIcon sx={{ fontSize: 20 }} />
                    </IconButton>
                    <IconButton
                      size="small"
                      sx={styles.socialButton}
                      onClick={() =>
                        window.open("https://discord.gg/DQa4z9jXnY", "_blank")
                      }
                    >
                      <img
                        src={discordIcon}
                        alt="Discord"
                        style={{ width: 20, height: 20 }}
                      />
                    </IconButton>
                    <IconButton
                      size="small"
                      sx={styles.socialButton}
                      onClick={() =>
                        window.open(
                          "https://github.com/provable-games/death-mountain",
                          "_blank"
                        )
                      }
                    >
                      <GitHubIcon sx={{ fontSize: 20 }} />
                    </IconButton>
                  </Box>
                </Box>
              </Box>
            </>
          )}
        </AnimatePresence>
        <StatisticsModal open={showStats} onClose={() => setShowStats(false)} />
      </Box>

      {showPaymentOptions && (
        <PaymentOptionsModal
          open={showPaymentOptions}
          onClose={() => setShowPaymentOptions(false)}
        />
      )}
    </>
  );
}

const styles = {
  container: {
    position: "absolute",
    top: 32,
    width: 310,
    minHeight: 600,
    bgcolor: "rgba(24, 40, 24, 0.55)",
    border: "2px solid #083e22",
    borderRadius: "12px",
    backdropFilter: "blur(8px)",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    px: 2,
    py: 1,
    zIndex: 10,
    gap: 1,
  },
  headerBox: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    mt: 2,
    mb: 0.5,
  },
  gameTitle: {
    fontSize: "1.6rem",
    fontWeight: 700,
    letterSpacing: 1,
    textAlign: "center",
    lineHeight: 1.1,
    mb: 0.5,
  },
  modeTitle: {
    fontSize: "1.5rem",
    fontWeight: 600,
    letterSpacing: 1,
    textAlign: "center",
    lineHeight: 1.1,
    mb: 0.5,
  },
  modeDescription: {
    fontSize: "1.1rem",
    fontWeight: 400,
    color: "#b6ffb6",
    fontStyle: "italic",
    letterSpacing: 0.5,
    textAlign: "center",
    textShadow: "0 1px 2px #0f0",
    mb: 1,
  },
  icon: {
    mr: 1,
  },
  bottom: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    mt: "auto",
    gap: 0.5,
    width: "100%",
  },
  bottomRow: {
    mt: 0.5,
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    width: "99%",
    mr: -1,
  },
  socialButtons: {
    display: "flex",
    gap: 0.5,
  },
  socialButton: {
    color: "#d0c98d",
    opacity: 0.8,
    "&:hover": {
      opacity: 1,
    },
    padding: "4px",
  },
  alphaVersion: {
    fontSize: "0.7rem",
    opacity: 0.8,
    letterSpacing: 1,
  },
  orDivider: {
    display: "flex",
    alignItems: "center",
    width: "100%",
  },
  orText: {
    margin: "0 1rem",
    fontSize: "0.8rem",
    opacity: 0.8,
    textAlign: "center",
  },
};
