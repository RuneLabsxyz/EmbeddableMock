use dojo::event::EventStorage;
use dojo::model::ModelStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
use starknet::get_caller_address;
use tournaments::components::interfaces::{IGameTokenDispatcher, IGameTokenDispatcherTrait};

#[derive(IntrospectPacked, Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    game_id: u64,
    hero_xp: u16,
}

#[generate_trait]
impl GameTraitImpl of GameTrait {
    fn update_metadata(self: Game, world: WorldStorage) {
        let (contract_address, _) = world.dns(@"game_systems").unwrap();
        let game_token_dispatcher = IGameTokenDispatcher { contract_address };
        game_token_dispatcher.emit_metadata_update(self.game_id.into());
    }
}