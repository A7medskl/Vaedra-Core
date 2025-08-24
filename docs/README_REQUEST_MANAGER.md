# Vaedra Request Manager

A modern, feature-rich request system for FiveM servers with custom UI notifications and queue management.

## 🚀 Quick Start

```lua
-- Create a request
Vaedra.RequestManager.createRequest(sourcePlayer, targetPlayer, "Title", "Description", callback)

-- Using exports
exports['Vaedra-Core']:createRequest(sourcePlayer, targetPlayer, "Title", "Description", callback)
```

## ✨ Features

- **Custom UI Notifications** - Beautiful notification cards with countdown timers
- **FIFO Queue System** - Multiple requests processed in order
- **30-Second Auto-Expiration** - Automatic timeout with visual countdown
- **Keyboard Controls** - Y to accept, N to decline
- **Sound Notifications** - Audio alerts for new requests
- **Player Disconnect Cleanup** - Automatic cleanup when players leave
- **Export Functions** - Easy integration with other resources

## 📖 Documentation

- **[Complete Documentation](docs/REQUEST_MANAGER.md)** - Full system overview and setup
- **[API Reference](docs/API_REFERENCE.md)** - Function parameters and return values
- **[Usage Examples](docs/EXAMPLES.md)** - Real-world implementation examples

## 🧪 Testing

Use the built-in test command:
```lua
/testrequest [target_player_id]
```

## 🎮 Player Controls

- **Y Key** - Accept request
- **N Key** - Decline request
- **Click Buttons** - Accept/Decline via UI buttons

## 🔧 Configuration

Edit `REQUEST_EXPIRE_TIME` in `Server/utils/requestsmanager.lua` to change expiration time:
```lua
local REQUEST_EXPIRE_TIME = 30000 -- 30 seconds
```

## 📁 File Structure

```
Vaedra-Core/
├── Server/utils/requestsmanager.lua    # Server logic
├── Client/utils/requestsmanager.lua    # Client logic  
├── web/                                # UI files
│   ├── index.html
│   ├── style.css
│   └── app.js
└── docs/                              # Documentation
    ├── REQUEST_MANAGER.md
    ├── API_REFERENCE.md
    └── EXAMPLES.md
```

## 🤝 Usage Examples

### Basic Request
```lua
Vaedra.RequestManager.createRequest(
    sourcePlayer, 
    targetPlayer, 
    "Friend Request", 
    "Want to be friends?",
    function(accepted, data)
        if accepted then
            print("Request accepted!")
        end
    end
)
```

### Trade System
```lua
exports['Vaedra-Core']:createRequest(
    seller, 
    buyer, 
    "Trade Offer", 
    "Buy weapon for $5000?",
    function(accepted, data)
        if accepted then
            ExecuteTrade(data.source, data.target, 5000)
        end
    end
)
```

## 🐛 Troubleshooting

**Request not showing?**
- Check if target player is online
- Verify resource is started
- Check console for errors

**N key not working?**
- Try clicking the Decline button
- Check if other resources are blocking inputs

**UI not displaying?**
- Check browser console (F12) for errors
- Restart the resource

## 📋 Requirements

- FiveM Server
- No additional dependencies
- Works with ESX, QB-Core, and standalone setups

## 🔄 Version

Current Version: **1.3**
- ✅ Custom UI notifications
- ✅ FIFO queue system  
- ✅ Keyboard controls (Y/N)
- ✅ Auto-expiration
- ✅ Complete documentation
