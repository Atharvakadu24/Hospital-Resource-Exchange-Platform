const RealTimeMonitor = (function() {
    let stompClient = null;

    function connect() {
        const socket = new SockJS('/ws-broker');
        stompClient = Stomp.over(socket);

        // Optional: Disable debug logs in console
        // stompClient.debug = null;

        stompClient.connect({}, function (frame) {
            console.log('Connected to Exchange Network: ' + frame);
            
            stompClient.subscribe('/topic/network-updates', function (notification) {
                const data = JSON.parse(notification.body);
                handleNotification(data);
            });
        }, function(error) {
            console.error('WebSocket Error: ' + error);
            // Reconnect logic
            setTimeout(connect, 5000);
        });
    }

    function handleNotification(data) {
        console.log('Incoming Network Event:', data);

        switch(data.type) {
            case 'RESOURCE_UPDATE':
                showToast('Inventory Update', `Resource #${data.resourceId} is now ${data.status}`, 'info');
                // Trigger soft refresh of marketplace if on that page
                if (window.location.pathname.includes('marketplace')) location.reload();
                break;
            case 'NEW_REQUEST':
                showToast('Priority Request', `${data.hospital} requested ${data.resourceType}`, 'warning');
                // Refetch activity table if on dashboard
                refreshActivityTable();
                break;
            case 'ALLOCATION_COMPLETE':
                showToast('Allocation Success', `${data.resourceName} assigned to ${data.hospital}`, 'success');
                refreshActivityTable();
                break;
        }
    }

    function showToast(title, message, type) {
        // SaaS-style notification using a simple dynamic alert or a library like Toastr/SweetAlert
        // Here we'll append a bootstrap toast to a container
        const container = document.getElementById('toast-container') || createToastContainer();
        const id = 'toast-' + Date.now();
        
        const html = `
            <div id="${id}" class="toast show animate-fade" role="alert" aria-live="assertive" aria-atomic="true" style="background: white; border-radius: 1rem; border-left: 5px solid var(--${type == 'info' ? 'primary' : type}); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);">
                <div class="toast-header border-0 bg-transparent">
                    <i class="fa-solid fa-bell me-2 text-${type == 'info' ? 'primary' : type}"></i>
                    <strong class="me-auto">${title}</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body small text-muted">
                    ${message}
                </div>
            </div>
        `;
        
        container.insertAdjacentHTML('beforeend', html);
        setTimeout(() => {
            const el = document.getElementById(id);
            if (el) el.remove();
        }, 5000);
    }

    function createToastContainer() {
        const div = document.createElement('div');
        div.id = 'toast-container';
        div.style.position = 'fixed';
        div.style.top = '1.5rem';
        div.style.right = '1.5rem';
        div.style.zIndex = '9999';
        div.style.display = 'flex';
        div.style.flexDirection = 'column';
        div.style.gap = '10px';
        div.style.width = '300px';
        document.body.appendChild(div);
        return div;
    }

    function refreshActivityTable() {
        // In a real SaaS app, we'd use htmx or fetch a partial JSP.
        // For this demo, we'll suggest a page refresh or leave it as a hook for future HTMX integration.
        // location.reload(); 
    }

    return {
        init: connect
    };
})();

document.addEventListener('DOMContentLoaded', RealTimeMonitor.init);
