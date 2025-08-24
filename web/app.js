class RequestNotification {
    constructor() {
        this.notification = document.getElementById('notification');
        this.timerProgress = document.getElementById('timerProgress');
        this.requestTitle = document.getElementById('requestTitle');
        this.requestFrom = document.getElementById('requestFrom');
        this.requestDescription = document.getElementById('requestDescription');
        this.acceptBtn = document.getElementById('acceptBtn');
        this.declineBtn = document.getElementById('declineBtn');
        
        this.currentRequest = null;
        this.timeLeft = 30;
        this.timerInterval = null;
        this.isVisible = false;
        
        this.init();
    }
    
    init() {
        // Button event listeners
        this.acceptBtn.addEventListener('click', () => this.respond(true));
        this.declineBtn.addEventListener('click', () => this.respond(false));
        
        // Keyboard event listeners
        document.addEventListener('keydown', (e) => {
            if (!this.isVisible) return;
            
            if (e.key.toLowerCase() === 'y') {
                e.preventDefault();
                this.respond(true);
            } else if (e.key.toLowerCase() === 'n') {
                e.preventDefault();
                this.respond(false);
            }
        });
        
        // NUI message listener
        window.addEventListener('message', (event) => {
            this.handleMessage(event.data);
        });
        
        console.log('[RequestNotification] UI initialized');
    }
    
    handleMessage(data) {
        switch (data.action) {
            case 'showRequest':
                this.showRequest(data.request);
                break;
                
            case 'hideRequest':
                this.hideRequest();
                break;
        }
    }
    
    showRequest(requestData) {
        this.currentRequest = requestData;
        this.timeLeft = 30;
        
        // Update UI content
        this.requestTitle.textContent = requestData.title;
        this.requestFrom.textContent = `From: ${requestData.sourceName}`;
        this.requestDescription.textContent = requestData.description;
        
        // Show notification by removing hidden class
        this.notification.classList.remove('hidden');
        this.isVisible = true;
        
        // Start timer
        this.startTimer();
        
        // Add urgent class for visual effect
        this.notification.classList.add('urgent');
        
        console.log('[RequestNotification] Showing request:', requestData.title);
    }
    
    hideRequest() {
        this.notification.classList.add('hidden');
        this.isVisible = false;
        this.currentRequest = null;
        
        // Clear timer
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
            this.timerInterval = null;
        }
        
        // Remove urgent class
        this.notification.classList.remove('urgent', 'expiring');
        
        console.log('[RequestNotification] Request hidden');
    }
    
    startTimer() {
        this.updateTimerDisplay();
        
        this.timerInterval = setInterval(() => {
            this.timeLeft--;
            this.updateTimerDisplay();
            
            // Add expiring animation when 10 seconds left
            if (this.timeLeft <= 10) {
                this.notification.classList.add('expiring');
            }
            
            // Auto-expire when time runs out
            if (this.timeLeft <= 0) {
                this.respond(false, true); // Auto-decline when expired
            }
        }, 1000);
    }
    
    updateTimerDisplay() {
        // Update progress bar width (starts at 100% and decreases)
        const progressPercent = (this.timeLeft / 30) * 100;
        this.timerProgress.style.width = `${progressPercent}%`;
        
        // Change color when expiring
        if (this.timeLeft <= 10) {
            this.timerProgress.style.background = 'linear-gradient(90deg, #f44336, #d32f2f)';
        } else {
            this.timerProgress.style.background = 'linear-gradient(90deg, #FF9800, #FF5722)';
        }
    }
    
    respond(accepted, expired = false) {
        if (!this.currentRequest) return;
        
        // Send response to Lua
        this.postMessage('respondToRequest', {
            requestId: this.currentRequest.id,
            response: accepted ? 'accept' : 'decline',
            expired: expired
        });
        
        // Hide notification
        this.hideRequest();
    }
    
    postMessage(callback, data) {
        if (typeof GetParentResourceName !== 'function') {
            console.warn('GetParentResourceName not available, using fallback');
            return;
        }
        
        fetch(`https://${GetParentResourceName()}/${callback}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).catch(err => console.error('NUI Callback Error:', err));
    }
}

// Initialize the notification system
const requestNotification = new RequestNotification();

// Make it globally available for debugging
window.requestNotification = requestNotification;