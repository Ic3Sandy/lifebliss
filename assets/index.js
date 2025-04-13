// Function to call Flutter with improved error handling
function callFlutter(message) {
    console.log("Attempting to call Flutter with: " + message);
    try {
        // Check if Flutter channel exists with proper error handling
        if (window.flutter && typeof window.flutter.postMessage === 'function') {
            window.flutter.postMessage(message);
            console.log("Message sent to Flutter successfully");
            return true;
        } else {
            if (!window.flutter) {
                console.error("Flutter channel not available - window.flutter is undefined");
            } else {
                console.error("Flutter channel exists but postMessage is not a function");
                console.error("Type of postMessage: " + typeof window.flutter.postMessage);
            }
            // Fall back to direct DOM manipulation
            if (message === 'titleClicked') {
                document.body.style.backgroundColor = "#FF8800";
            }
            return false;
        }
    } catch (e) {
        console.error("Error calling Flutter: " + e);
        return false;
    }
}

// Function to verify Flutter channel is ready
function checkFlutterChannel() {
    if (window.flutter && typeof window.flutter.postMessage === 'function') {
        console.log("Flutter channel is ready and functional");
        return true;
    }
    console.warn("Flutter channel not ready yet");
    return false;
}

// Function to set up the title element with click listeners
function setupTitleElement() {
    console.log("Setting up title element");
    const titleElement = document.getElementById('app-title');
    if (titleElement) {
        // Ensure positioning is handled by CSS
        // Remove any inline styles that might conflict
        titleElement.removeAttribute('style');
        
        // Add single click event handler with better error handling
        titleElement.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            console.log("Title clicked - requesting random color");
            
            // First change color locally as fallback
            document.body.style.backgroundColor = "#FF8800";
            
            // Then try to notify Flutter
            setTimeout(function() {
                callFlutter("titleClicked");
            }, 0); // Use timeout to avoid blocking the UI
        });

        // Mark the element as initialized
        titleElement.setAttribute('data-initialized', 'true');

        console.log("Click handlers attached successfully");
        
        // Verify positioning
        setTimeout(function() {
            const rect = titleElement.getBoundingClientRect();
            const centerX = window.innerWidth / 2;
            const centerY = window.innerHeight / 2;
            const isNearCenter = 
                Math.abs(rect.left + rect.width/2 - centerX) < 50 && 
                Math.abs(rect.top + rect.height/2 - centerY) < 50;
            
            console.log(`Title positioning: left=${rect.left}, top=${rect.top}, width=${rect.width}, height=${rect.height}`);
            console.log(`Window center: x=${centerX}, y=${centerY}`);
            console.log(`Title is ${isNearCenter ? 'centered' : 'NOT centered'}`);
            
            if (!isNearCenter) {
                console.warn("Title element is not properly centered - applying fix");
                document.body.style.display = 'flex';
                document.body.style.justifyContent = 'center';
                document.body.style.alignItems = 'center';
                document.body.style.minHeight = '100vh';
            }
        }, 500);
    } else {
        console.error("Could not find app-title element");
    }
}

// Initialize when DOM is ready
function initializeApp() {
    console.log("DOM content loaded - setting up title element");
    setupTitleElement();
    
    // Check Flutter channel after a delay
    setTimeout(function() {
        checkFlutterChannel();
    }, 500);
}

// Set up event listeners when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', initializeApp);

// Fallback for window load event
window.addEventListener('load', function() {
    console.log("Window loaded - checking if title setup is needed");
    const titleElement = document.getElementById('app-title');
    if (titleElement && !titleElement.hasAttribute('data-initialized')) {
        console.log("Title not set up yet - setting up now");
        setupTitleElement();
    }
    
    // Check Flutter channel again
    checkFlutterChannel();
}); 