# ⚡ QUICK REFERENCE - Firebase Diagnostic

## 🎯 What To Do Now (Next 5 Minutes)

### Step 1: Open DevTools
```
Press: F12
Click: Console tab
Click: Clear button
```

### Step 2: Fill Registration Form
```
Email:        test@example.com
Name:         John Doe
Phone:        +212612345678
Password:     password123
```

### Step 3: Click Register & Watch Console

### Step 4: Copy Error Code (if error)
```
Look for: Code: [SOMETHING]
Copy it and send to me
```

---

## 🎯 What The Logs Look Like

### ✅ SUCCESS
```
🎉 === REGISTRATION SUCCESS ===
```

### ❌ ERROR (Example)
```
Code: operation-not-allowed
Message: Password sign-in is disabled...
```

---

## 🔧 Common Error Codes & Solutions

| Code | Problem | Fix |
|------|---------|-----|
| `operation-not-allowed` | Email/Password disabled | Enable in Firebase Console → Auth → Sign-in Method |
| `invalid-api-key` | Bad API key | Check Google Cloud restrictions |
| `email-already-in-use` | Email exists | Use different email |
| `weak-password` | Password < 6 chars | Use longer password |
| `network-request-failed` | Network/CORS error | Add localhost to authorized domains |

---

## 📋 Checklist

- [ ] F12 opened (DevTools)
- [ ] Console tab selected
- [ ] Console cleared
- [ ] Form filled with test data
- [ ] Register button clicked
- [ ] Waited 2-3 seconds
- [ ] Checked Console for message
- [ ] Copied error code (if error)
- [ ] Ready to report

---

## 📄 Read First
1. **`START_HERE.md`** ⭐ Simple instructions
2. **`TESTING_CHECKLIST.md`** ✅ Detailed steps
3. **`CONSOLE_OUTPUT_EXAMPLES.md`** 📊 Expected outputs

---

## 🚀 Current Status
- ✅ App running in Chrome
- ✅ Enhanced logging added
- ✅ Documentation complete
- ⏳ Waiting for your test result

---

**That's it! You're ready to test!** 🎯
