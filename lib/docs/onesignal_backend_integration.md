# OneSignal Backend Integration Guide

This document explains how to integrate OneSignal push notifications with your backend to send notifications to users.

## Overview

The Flutter app automatically subscribes users to OneSignal when they log in, using their user ID as the external user ID. This allows the backend to send targeted notifications to specific users.

## OneSignal Configuration

### App ID
- **OneSignal App ID**: `265c7eec-d1f5-4bd2-8a15-629eb0970f7d`
- **Platform**: Android/iOS

### User Identification
- Users are automatically subscribed using their user ID as the external user ID
- This allows sending notifications to specific users by their user ID

## Backend Integration

### 1. OneSignal REST API

Use OneSignal's REST API to send notifications from your backend:

```bash
POST https://onesignal.com/api/v1/notifications
```

### 2. Authentication

Include your OneSignal REST API key in the request headers:

```http
Authorization: Basic YOUR_REST_API_KEY
Content-Type: application/json
```

### 3. Notification Payload Examples

#### Service Approval Notification

```json
{
  "app_id": "265c7eec-d1f5-4bd2-8a15-629eb0970f7d",
  "include_external_user_ids": ["USER_ID_HERE"],
  "headings": {
    "en": "Service Approved!"
  },
  "contents": {
    "en": "Your service has been approved and is now live."
  },
  "data": {
    "type": "service_approved",
    "service_id": "SERVICE_ID_HERE",
    "action": "view_service"
  },
  "url": "riderescue://service/SERVICE_ID_HERE"
}
```

#### Service Rejection Notification

```json
{
  "app_id": "265c7eec-d1f5-4bd2-8a15-629eb0970f7d",
  "include_external_user_ids": ["USER_ID_HERE"],
  "headings": {
    "en": "Service Update Required"
  },
  "contents": {
    "en": "Your service needs some updates before approval."
  },
  "data": {
    "type": "service_rejected",
    "service_id": "SERVICE_ID_HERE",
    "reason": "REJECTION_REASON",
    "action": "edit_service"
  },
  "url": "riderescue://service/SERVICE_ID_HERE/edit"
}
```

#### New Request Notification

```json
{
  "app_id": "265c7eec-d1f5-4bd2-8a15-629eb0970f7d",
  "include_external_user_ids": ["USER_ID_HERE"],
  "headings": {
    "en": "New Service Request"
  },
  "contents": {
    "en": "You have a new service request from a customer."
  },
  "data": {
    "type": "new_request",
    "request_id": "REQUEST_ID_HERE",
    "action": "view_request"
  },
  "url": "riderescue://requests/REQUEST_ID_HERE"
}
```

#### Payment Received Notification

```json
{
  "app_id": "265c7eec-d1f5-4bd2-8a15-629eb0970f7d",
  "include_external_user_ids": ["USER_ID_HERE"],
  "headings": {
    "en": "Payment Received"
  },
  "contents": {
    "en": "You received a payment of $50.00 for your service."
  },
  "data": {
    "type": "payment_received",
    "amount": "50.00",
    "currency": "USD",
    "transaction_id": "TXN_ID_HERE",
    "action": "view_payment"
  },
  "url": "riderescue://payments/TXN_ID_HERE"
}
```

## Backend Implementation Examples

### Node.js/Express Example

```javascript
const axios = require('axios');

const ONESIGNAL_APP_ID = '265c7eec-d1f5-4bd2-8a15-629eb0970f7d';
const ONESIGNAL_REST_API_KEY = 'YOUR_REST_API_KEY';

async function sendNotification(userId, title, message, data = {}) {
  try {
    const response = await axios.post(
      'https://onesignal.com/api/v1/notifications',
      {
        app_id: ONESIGNAL_APP_ID,
        include_external_user_ids: [userId],
        headings: {
          en: title
        },
        contents: {
          en: message
        },
        data: data
      },
      {
        headers: {
          'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    console.log('Notification sent successfully:', response.data);
    return response.data;
  } catch (error) {
    console.error('Failed to send notification:', error.response?.data || error.message);
    throw error;
  }
}

// Example: Send service approval notification
async function notifyServiceApproved(userId, serviceId) {
  await sendNotification(
    userId,
    'Service Approved!',
    'Your service has been approved and is now live.',
    {
      type: 'service_approved',
      service_id: serviceId,
      action: 'view_service'
    }
  );
}

// Example: Send service rejection notification
async function notifyServiceRejected(userId, serviceId, reason) {
  await sendNotification(
    userId,
    'Service Update Required',
    'Your service needs some updates before approval.',
    {
      type: 'service_rejected',
      service_id: serviceId,
      reason: reason,
      action: 'edit_service'
    }
  );
}
```

### Python/Django Example

```python
import requests
import json

ONESIGNAL_APP_ID = '265c7eec-d1f5-4bd2-8a15-629eb0970f7d'
ONESIGNAL_REST_API_KEY = 'YOUR_REST_API_KEY'

def send_notification(user_id, title, message, data=None):
    """Send a push notification to a specific user"""
    
    if data is None:
        data = {}
    
    payload = {
        'app_id': ONESIGNAL_APP_ID,
        'include_external_user_ids': [user_id],
        'headings': {
            'en': title
        },
        'contents': {
            'en': message
        },
        'data': data
    }
    
    headers = {
        'Authorization': f'Basic {ONESIGNAL_REST_API_KEY}',
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.post(
            'https://onesignal.com/api/v1/notifications',
            data=json.dumps(payload),
            headers=headers
        )
        response.raise_for_status()
        
        print(f'Notification sent successfully to user {user_id}')
        return response.json()
        
    except requests.exceptions.RequestException as e:
        print(f'Failed to send notification: {e}')
        raise

# Example: Send service approval notification
def notify_service_approved(user_id, service_id):
    send_notification(
        user_id,
        'Service Approved!',
        'Your service has been approved and is now live.',
        {
            'type': 'service_approved',
            'service_id': service_id,
            'action': 'view_service'
        }
    )

# Example: Send service rejection notification
def notify_service_rejected(user_id, service_id, reason):
    send_notification(
        user_id,
        'Service Update Required',
        'Your service needs some updates before approval.',
        {
            'type': 'service_rejected',
            'service_id': service_id,
            'reason': reason,
            'action': 'edit_service'
        }
    )
```

## Notification Types and Actions

The app handles different notification types based on the `type` field in the notification data:

| Type | Description | Action |
|------|-------------|--------|
| `service_approved` | Service has been approved | Navigate to service details |
| `service_rejected` | Service has been rejected | Navigate to service edit |
| `new_request` | New service request received | Navigate to requests screen |
| `payment_received` | Payment received | Navigate to payments screen |

## Deep Linking

Use the `url` field in notifications to implement deep linking:

- `riderescue://service/{service_id}` - Open service details
- `riderescue://service/{service_id}/edit` - Open service edit
- `riderescue://requests/{request_id}` - Open request details
- `riderescue://payments/{transaction_id}` - Open payment details

## Testing

### Test User Subscription

1. Log in to the app with a test user
2. Check the console logs for OneSignal subscription messages
3. Verify the user ID is being used as the external user ID

### Test Notification Sending

1. Use the OneSignal dashboard to send a test notification
2. Use the REST API examples above to send test notifications
3. Verify notifications are received in the app

## Security Considerations

1. **API Key Security**: Keep your OneSignal REST API key secure
2. **User ID Validation**: Always validate user IDs before sending notifications
3. **Rate Limiting**: Implement rate limiting for notification sending
4. **Error Handling**: Handle notification sending errors gracefully

## Troubleshooting

### Common Issues

1. **User not receiving notifications**
   - Check if user is properly subscribed (check console logs)
   - Verify user ID is correct
   - Check notification permissions

2. **Notifications not showing**
   - Check OneSignal initialization
   - Verify notification handlers are set up
   - Check device notification settings

3. **Backend sending errors**
   - Verify REST API key is correct
   - Check payload format
   - Verify app ID is correct

### Debug Information

The app logs OneSignal events to the console:
- User subscription status
- Notification received events
- Notification click events
- Error messages

Check these logs for debugging information. 