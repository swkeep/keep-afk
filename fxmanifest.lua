--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep

fx_version 'cerulean'
game 'gta5'

description 'Keep-afk'
version '1.0.0'

client_script { 'client/afk.lua' }
server_script { 'config.lua', 'server/afk.lua', }

lua54 'yes'
