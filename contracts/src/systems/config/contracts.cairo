use darkshuffle::models::config::{CardRarityWeights, GameSettings, GameSettingsMetadata};
use starknet::ContractAddress;

#[starknet::interface]
trait IConfigSystems<T> {
    fn setting_details(self: @T, settings_id: u32) -> GameSettings;
    fn settings_exists(self: @T, settings_id: u32) -> bool;
    fn game_settings(self: @T, game_id: u64) -> GameSettings;
}

#[dojo::contract]
mod config_systems {
    use achievement::components::achievable::AchievableComponent;
    use darkshuffle::constants::DEFAULT_SETTINGS::GET_DEFAULT_SETTINGS;
    use darkshuffle::constants::{DEFAULT_NS, VERSION};
    use darkshuffle::models::config::{
        BattleSettings, CardRarityWeights, DraftSettings, GameSettings, GameSettingsMetadata, GameSettingsTrait,
        MapSettings, SettingsCounter,
    };
    use darkshuffle::utils::ConfigUtilsImpl;
    use dojo::model::ModelStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use tournaments::components::models::game::TokenMetadata;

    component!(path: AchievableComponent, storage: achievable, event: AchievableEvent);
    impl AchievableInternalImpl = AchievableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievable: AchievableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievableEvent: AchievableComponent::Event,
    }

    fn dojo_init(self: @ContractState) {

    }

    #[abi(embed_v0)]
    impl ConfigSystemsImpl of super::IConfigSystems<ContractState> {

        fn setting_details(self: @ContractState, settings_id: u32) -> GameSettings {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings
        }

        fn settings_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            settings.exists()
        }

        fn game_settings(self: @ContractState, game_id: u64) -> GameSettings {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);
            let game_settings: GameSettings = world.read_model(token_metadata.settings_id);
            game_settings
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn validate_settings(self: @ContractState, settings: GameSettings) {
            assert!(settings.starting_health > 0, "Starting health must be greater than 0");
            assert!(settings.starting_health <= 200, "Maximum starting health cannot be greater than 200");

            assert!(settings.draft.draft_size > 0, "Draft size must be greater than 0 cards");
            assert!(settings.draft.draft_size <= 50, "Maximum draft size is 50 cards");

            assert!(settings.battle.max_energy > 0, "Maximum energy must be greater than 0");
            assert!(settings.battle.max_energy <= 50, "Maximum energy cannot be greater than 50");

            assert!(settings.battle.start_energy > 0, "Starting energy must be greater than 0");
            assert!(settings.battle.start_energy <= 50, "Maximum starting energy cannot be greater than 50");

            assert!(settings.battle.start_hand_size > 0, "Starting hand size must be greater than 0 cards");
            assert!(
                settings.battle.start_hand_size <= 10, "Maximum starting hand size cannot be greater than 10 cards",
            );

            assert!(settings.battle.max_hand_size > 0, "Maximum hand size must be greater than 0 cards");
            assert!(settings.battle.max_hand_size <= 10, "Maximum hand size cannot be greater than 10 cards");

            assert!(settings.draft.card_ids.len() >= 3, "Minimum 3 draftable cards");

            assert!(settings.battle.draw_amount > 0, "Draw amount must be greater than 0");
            assert!(settings.battle.draw_amount <= 5, "Maximum draw amount cannot be greater than 5");

            assert!(settings.draft.card_rarity_weights.common <= 10, "Common rarity weight cannot be greater than 10");
            assert!(
                settings.draft.card_rarity_weights.uncommon <= 10, "Uncommon rarity weight cannot be greater than 10",
            );
            assert!(settings.draft.card_rarity_weights.rare <= 10, "Rare rarity weight cannot be greater than 10");
            assert!(settings.draft.card_rarity_weights.epic <= 10, "Epic rarity weight cannot be greater than 10");
            assert!(
                settings.draft.card_rarity_weights.legendary <= 10, "Legendary rarity weight cannot be greater than 10",
            );

            assert!(settings.map.possible_branches > 0, "Maximum branches must be greater than 0");
            assert!(settings.map.possible_branches <= 3, "Maximum branches cannot be greater than 3");

            assert!(settings.map.level_depth > 0, "Level depth must be greater than 0");
            assert!(settings.map.level_depth <= 5, "Level depth cannot be greater than 5");

            assert!(settings.map.enemy_attack_min > 0, "Enemy attack minimum must be greater than 0");
            assert!(settings.map.enemy_attack_min <= 10, "Enemy attack minimum cannot be greater than 10");
            assert!(
                settings.map.enemy_attack_max >= settings.map.enemy_attack_min,
                "Enemy attack cannot be less than minimum",
            );
            assert!(settings.map.enemy_attack_max <= 10, "Enemy attack maximum cannot be greater than 10");

            assert!(settings.map.enemy_health_min >= 10, "Enemy health minimum cannot be less than 10");
            assert!(settings.map.enemy_health_min <= 200, "Enemy health minimum cannot be greater than 200");
            assert!(
                settings.map.enemy_health_max >= settings.map.enemy_health_min,
                "Enemy health cannot be less than minimum",
            );
            assert!(settings.map.enemy_health_max <= 200, "Enemy health maximum cannot be greater than 200");

            assert!(settings.map.enemy_attack_scaling <= 10, "Enemy attack scaling cannot be greater than 10");
            assert!(settings.map.enemy_health_scaling <= 50, "Enemy health scaling cannot be greater than 50");
        }
    }
}
