# Optional: Integrate Notification Bell Icon to Topbar

This guide shows how to add a notification bell icon with unread count to your existing Topbar component.

## Option 1: Simple Bell Icon with Unread Count

Add this to your Topbar component to display notifications:

### Update Topbar.jsx

```jsx
// Add to imports
import { BellOutlined } from '@ant-design/icons';

// Add state for notifications
const [unreadNotificationCount, setUnreadNotificationCount] = useState(0);

// Add this useEffect to fetch unread count
useEffect(() => {
  const fetchUnreadCount = async () => {
    try {
      const token = getAuthToken();
      if (!token || isSuperAdmin) return;
      
      const res = await axios.get('/notifications/unread/count', {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      if (res.data?.success) {
        setUnreadNotificationCount(res.data.data.unreadCount || 0);
      }
    } catch (err) {
      console.warn('Could not fetch unread notifications:', err.message);
    }
  };
  
  fetchUnreadCount();
  
  // Refresh every 30 seconds
  const interval = setInterval(fetchUnreadCount, 30000);
  return () => clearInterval(interval);
}, [isSuperAdmin]);

// Add this to your topbar right side (with other icons)
// In the topbar right section where you have other icons:
<Button
  type="text"
  icon={
    <Badge 
      count={unreadNotificationCount} 
      style={{ backgroundColor: '#ff4d4f' }}
    >
      <BellOutlined 
        style={{ 
          color: '#fff', 
          fontSize: '18px',
          cursor: 'pointer' 
        }}
        onClick={() => navigate('/notifications')}
      />
    </Badge>
  }
/>
```

## Option 2: Notification Bell Dropdown

For a dropdown showing recent notifications:

```jsx
const [recentNotifications, setRecentNotifications] = useState([]);

// Fetch recent notifications
const fetchRecentNotifications = async () => {
  try {
    const token = getAuthToken();
    if (!token || isSuperAdmin) return;
    
    const res = await axios.get('/notifications?page=1&limit=5', {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (res.data?.success) {
      setRecentNotifications(res.data.data.notifications || []);
    }
  } catch (err) {
    console.warn('Error fetching notifications:', err.message);
  }
};

const notificationItems = recentNotifications.map(notif => ({
  key: notif.id,
  label: (
    <div style={{ padding: '8px 0' }}>
      <div style={{ fontWeight: 'bold', fontSize: '12px', color: notif.isRead ? '#999' : '#000' }}>
        {notif.title}
      </div>
      <div style={{ fontSize: '11px', color: '#999', marginTop: '2px' }}>
        {notif.message.substring(0, 50)}...
      </div>
      <div style={{ fontSize: '10px', color: '#ccc', marginTop: '4px' }}>
        {new Date(notif.createdAt).toLocaleTimeString()}
      </div>
    </div>
  ),
  onClick: () => navigate(`/notifications/${notif.id}`)
}));

// Add this dropdown component:
<Dropdown
  menu={{ 
    items: [
      ...notificationItems,
      notificationItems.length > 0 ? { type: 'divider' } : null,
      {
        key: 'view-all',
        label: 'View All',
        onClick: () => navigate('/notifications')
      }
    ].filter(Boolean)
  }}
  placement="bottomRight"
  trigger={['click']}
>
  <Button
    type="text"
    icon={
      <Badge 
        count={unreadNotificationCount} 
        style={{ backgroundColor: '#ff4d4f' }}
      >
        <BellOutlined style={{ color: '#fff', fontSize: '18px' }} />
      </Badge>
    }
  />
</Dropdown>
```

## Option 3: Full Notification Center Modal

For a full modal with all notifications:

```jsx
const [notificationModal, setNotificationModal] = useState(false);

const handleOpenNotificationCenter = async () => {
  await fetchRecentNotifications();
  setNotificationModal(true);
};

// Bell Button
<Button
  type="text"
  icon={
    <Badge 
      count={unreadNotificationCount} 
      style={{ backgroundColor: '#ff4d4f' }}
    >
      <BellOutlined 
        style={{ color: '#fff', fontSize: '18px' }}
        onClick={handleOpenNotificationCenter}
      />
    </Badge>
  }
/>

// Modal for notification center
<Modal
  title={`Notifications (${unreadNotificationCount} unread)`}
  open={notificationModal}
  onCancel={() => setNotificationModal(false)}
  width={600}
>
  <List
    dataSource={recentNotifications}
    renderItem={(notif) => (
      <List.Item
        style={{
          background: notif.isRead ? '#fff' : '#f0f5ff',
          padding: '12px',
          borderRadius: '4px',
          marginBottom: '8px',
          cursor: 'pointer',
          border: `1px solid ${notif.isRead ? '#e8e8e8' : '#91d5ff'}`
        }}
        onClick={() => {
          navigate(`/notifications/${notif.id}`);
          setNotificationModal(false);
        }}
      >
        <List.Item.Meta
          title={
            <div>
              <span style={{ fontWeight: notif.isRead ? 'normal' : 'bold' }}>
                {notif.title}
              </span>
              {!notif.isRead && (
                <Badge status="processing" style={{ marginLeft: '8px' }} />
              )}
            </div>
          }
          description={
            <div>
              <p style={{ margin: '4px 0', color: '#595959' }}>
                {notif.message.substring(0, 100)}...
              </p>
              <small style={{ color: '#8c8c8c' }}>
                {new Date(notif.createdAt).toLocaleString()}
              </small>
            </div>
          }
        />
      </List.Item>
    )}
  />
  <Button 
    type="primary" 
    block 
    onClick={() => {
      navigate('/notifications');
      setNotificationModal(false);
    }}
    style={{ marginTop: '12px' }}
  >
    View All Notifications
  </Button>
</Modal>
```

## Implementation Steps

1. **Choose one option above** (Simple, Dropdown, or Modal)

2. **Update Topbar.jsx** with the code

3. **Add necessary imports:**
```jsx
import { BellOutlined } from '@ant-design/icons';
import { Badge, Dropdown, Modal, List } from 'antd';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
```

4. **Add to Topbar right section** (where other icons are)

5. **Test the integration:**
   - Create a notification as super admin
   - Check if bell icon shows unread count
   - Click bell to open notifications
   - Verify unread count updates after viewing

## Complete Example - Modified Topbar Section

Here's how your Topbar right section might look:

```jsx
<div style={{
  display: 'flex',
  alignItems: 'center',
  gap: '16px',
}}>
  {/* Notification Bell */}
  {!isSuperAdmin && (
    <Button
      type="text"
      icon={
        <Badge 
          count={unreadNotificationCount} 
          style={{ backgroundColor: '#ff4d4f' }}
        >
          <BellOutlined 
            style={{ color: '#fff', fontSize: '18px' }}
            onClick={() => navigate('/notifications')}
            title={`${unreadNotificationCount} unread notifications`}
          />
        </Badge>
      }
    />
  )}

  {/* Existing icons */}
  <Button
    type="text"
    icon={<SettingOutlined />}
    onClick={handSettingsClick}
  />
  
  {/* User dropdown */}
  <Dropdown menu={{ items: userMenuItems }}>
    <Avatar icon={<UserOutlined />} />
  </Dropdown>
</div>
```

## CSS Enhancements (Optional)

Add to your Topbar.css:

```css
.notification-bell {
  cursor: pointer;
  transition: all 0.3s ease;
}

.notification-bell:hover {
  transform: scale(1.1);
  filter: drop-shadow(0 0 6px rgba(255, 77, 79, 0.5));
}

.notification-bell-badge {
  background-color: #ff4d4f !important;
  color: white;
}

/* Animation for new notification */
@keyframes bellRing {
  0%, 100% { transform: rotate(0) }
  25% { transform: rotate(-15deg) }
  75% { transform: rotate(15deg) }
}

.notification-bell.has-unread {
  animation: bellRing 0.5s ease-in-out;
}
```

## Variables to Track

```jsx
// Unread count
const [unreadNotificationCount, setUnreadNotificationCount] = useState(0);

// Recent notifications for dropdown
const [recentNotifications, setRecentNotifications] = useState([]);

// Modal open/close
const [notificationModal, setNotificationModal] = useState(false);

// Auto-refresh interval
const [refreshInterval, setRefreshInterval] = useState(null);
```

## Suggested Position in Topbar

```
Header Layout:
┌─────────────────────────────────────────────────────────┐
│ Logo | Menu  [Icons Section]  [Notification Bell] [User] │
│                                                          │
│                                   ← Bell icon here       │
└─────────────────────────────────────────────────────────┘
```

## Performance Tips

1. **Debounce Unread Count Fetch** - Only refresh every 30 seconds
2. **Lazy Load Recent Notifications** - Only fetch when dropdown opens  
3. **Background Sync** - Use WebSocket for real-time updates (optional)
4. **Cache Notifications** - Store in local state to reduce API calls

## Real-Time Updates (Advanced)

For real-time notifications without polling:

```jsx
// Using Server-Sent Events (SSE)
useEffect(() => {
  const token = getAuthToken();
  const eventSource = new EventSource(`/notifications/stream?token=${token}`);
  
  eventSource.onmessage = (event) => {
    const notification = JSON.parse(event.data);
    setUnreadNotificationCount(prev => prev + 1);
    // Show notification toast
    message.info(`New notification: ${notification.title}`);
  };
  
  return () => eventSource.close();
}, []);
```

---

This integration will give your users a seamless notification experience right from the Topbar!
