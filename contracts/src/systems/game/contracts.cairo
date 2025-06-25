use starknet::ContractAddress;
use darkshuffle::utils::ConfigUtilsImpl;

#[starknet::interface]
trait IGameSystems<T> {
    fn start_game(ref self: T, game_id: u64);
    fn take_turn(ref self: T, game_id: u64);
}

#[dojo::contract]
mod game_systems {
    use achievement::store::{Store, StoreTrait};
    use darkshuffle::constants::{DEFAULT_NS, SCORE_ATTRIBUTE, SCORE_MODEL, SETTINGS_MODEL};
    use darkshuffle::models::{
        config::{GameSettings, GameSettingsTrait}, game::{Game, GameTrait},
    };
    use darkshuffle::renderer::utils::create_metadata;
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait, IERC721Metadata};
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};

    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_tx_info};

    use tournaments::components::game::game_component;
    use tournaments::components::interfaces::{IGameDetails, IGameToken, ISettings};
    use tournaments::components::libs::lifecycle::{LifecycleAssertionsImpl, LifecycleAssertionsTrait};
    use tournaments::components::models::game::TokenMetadata;
    use tournaments::components::models::lifecycle::Lifecycle;

    component!(path: game_component, storage: game, event: GameEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);

    #[abi(embed_v0)]
    impl GameImpl = game_component::GameImpl<ContractState>;
    impl GameInternalImpl = game_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnlyImpl = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        game: game_component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        GameEvent: game_component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    fn dojo_init(ref self: ContractState, creator_address: ContractAddress) {
        self.erc721.initializer("Dark Shuffle", "DARK", "darkshuffle.io");
        self
            .game
            .initializer(
                creator_address,
                'Dark Shuffle',
                "Dark Shuffle is a turn-based, collectible card game. Build your deck, battle monsters, and explore a procedurally generated world.",
                'Provable Games',
                'Provable Games',
                'Digital TCG / Deck Building',
                "https://darkshuffle.io/favicon.svg",
                DEFAULT_NS(),
                SCORE_MODEL(),
                SCORE_ATTRIBUTE(),
                SETTINGS_MODEL(),
            );
    }

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn setting_exists(self: @ContractState, settings_id: u32) -> bool {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let settings: GameSettings = world.read_model(settings_id);
            true
        }
    }

    #[abi(embed_v0)]
    impl GameDetailsImpl of IGameDetails<ContractState> {
        fn score(self: @ContractState, game_id: u64) -> u32 {
            let world: WorldStorage = self.world(@DEFAULT_NS());
            let game: Game = world.read_model(game_id);
            69
        }
    }

    #[abi(embed_v0)]
    impl GameSystemsImpl of super::IGameSystems<ContractState> {
        fn start_game(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            let token_metadata: TokenMetadata = world.read_model(game_id);

            self.validate_start_conditions(game_id, @token_metadata);

            let mut game = Game {
                game_id,
                hero_xp: 1,
            };

            world.write_model(@game);
          
            game.update_metadata(world);
        }

        fn take_turn(ref self: ContractState, game_id: u64) {
            let mut world: WorldStorage = self.world(@DEFAULT_NS());
            let mut game: Game = world.read_model(game_id);
            game.hero_xp += 1;
            game.update_metadata(world);
            world.write_model(@game);
        }

    }

    #[abi(embed_v0)]
    impl ERC721Metadata of IERC721Metadata<ContractState> {
        /// Returns the NFT name.
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_name.read()
        }

        /// Returns the NFT symbol.
        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_symbol.read()
        }

        /// Returns the Uniform Resource Identifier (URI) for the `token_id` token.
        /// If the URI is not set, the return value will be an empty ByteArray.
        ///
        /// Requirements:
        ///
        /// - `token_id` exists.
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721._require_owned(token_id);

            let token_id_u64 = token_id.try_into().unwrap();


            create_metadata(token_id_u64, 'test')
        }
    }



#[generate_trait]
impl InternalImpl of InternalTrait {
    #[inline(always)]
    fn validate_start_conditions(self: @ContractState, token_id: u64, token_metadata: @TokenMetadata) {
        self.assert_token_ownership(token_id);
        self.assert_game_not_started(token_id);
        token_metadata.lifecycle.assert_is_playable(token_id, starknet::get_block_timestamp());
    }

    #[inline(always)]
    fn assert_token_ownership(self: @ContractState, token_id: u64) {
        let token_owner = ERC721Impl::owner_of(self, token_id.into());
        assert!(
            token_owner == starknet::get_caller_address(),
            "Dark Shuffle: Caller is not owner of token {}",
            token_id,
        );
    }

    #[inline(always)]
    fn assert_game_not_started(self: @ContractState, game_id: u64) {
        let game: Game = self.world(@DEFAULT_NS()).read_model(game_id);
        assert!(game.hero_xp == 0, "Dark Shuffle: Game {} has already started", game_id);
    }
}
}