const express = require('express');
const router = express.Router();
const db = require('../db/db');

// Helper function to capitalize all words
const capitalizeWords = (str) => {
    if (!str) return str;
    return str.split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ');
};

// Authentication Routes
router.post('/auth/login', async (req, res) => {
    const { username, password } = req.body;
    
    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password are required' });
    }

    try {
        // Query the database for the user with username and password
        const users = await db.query(
            'SELECT * FROM user_login WHERE username = ? AND password = ?',
            [username, password]
        );

        if (users.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const user = users[0];
        return res.json({
            success: true,
            user: {
                id: user.id,
                username: user.username
            }
        });
    } catch (err) {
        console.error('Login error:', err);
        return res.status(500).json({ error: 'Internal server error' });
    }
});

// Users Routes
router.get('/api/users', async (req, res) => {
    try {
        const users = await db.query(`
            SELECT 
                u.id,
                u.name,
                u.position,
                u.url_photo,
                COALESCE(SUM(s.score), 0) as total_score,
                COUNT(DISTINCT s.id) as activities_count
            FROM users u
            LEFT JOIN scores s ON u.id = s.user_id
            GROUP BY u.id, u.name, u.position, u.url_photo
            ORDER BY total_score DESC
        `);
        
        // Add rank to each user
        const rankedUsers = users.map((user, index) => ({
            ...user,
            rank: index + 1
        }));
        
        res.json(rankedUsers);
    } catch (err) {
        console.error('Error fetching users:', err);
        res.status(500).json({ error: 'Error fetching users' });
    }
});

// Add new user
router.post('/api/users', async (req, res) => {
    const { name, position, url_photo } = req.body;
    
    // Validate input
    if (!name || !position || !url_photo) {
        return res.status(400).json({ error: 'Name, position, and url_photo are required' });
    }

    // Capitalize both name and position
    const capitalizedName = capitalizeWords(name);
    const capitalizedPosition = capitalizeWords(position);

    try {
        const result = await db.query(
            'INSERT INTO users (name, position, url_photo) VALUES (?, ?, ?)',
            [capitalizedName, capitalizedPosition, url_photo]
        );
        res.status(201).json({ 
            message: 'User created successfully',
            userId: result.insertId,
            user: { 
                name: capitalizedName, 
                position: capitalizedPosition,
                url_photo: url_photo
            }
        });
    } catch (err) {
        console.error('Error creating user:', err);
        res.status(500).json({ error: 'Error creating user' });
    }
});

// Scores Routes
router.get('/api/scores', async (req, res) => {
    try {
        const scores = await db.query(`
            SELECT 
                s.id as score_id,
                s.score,
                u.id as user_id,
                u.name as user_name,
                u.position as user_position,
                u.url_photo as user_photo
            FROM scores s
            INNER JOIN users u ON s.user_id = u.id
            ORDER BY s.score DESC, s.id DESC
        `);
        res.json(scores);
    } catch (err) {
        console.error('Error fetching scores:', err);
        res.status(500).json({ error: 'Error fetching scores' });
    }
});

router.post('/api/scores/update', async (req, res) => {
    const { userId, score } = req.body;
    
    if (!userId || score === undefined) {
        return res.status(400).json({ error: 'userId and score are required' });
    }

    try {
        // First check if the user exists
        const userExists = await db.query('SELECT id FROM users WHERE id = ?', [userId]);
        
        if (userExists.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if user already has a score
        const existingScore = await db.query('SELECT id FROM scores WHERE user_id = ?', [userId]);

        let result;
        if (existingScore.length > 0) {
            // Update existing score
            result = await db.query(
                'UPDATE scores SET score = ? WHERE user_id = ?',
                [score, userId]
            );
        } else {
            // Insert new score
            result = await db.query(
                'INSERT INTO scores (user_id, score) VALUES (?, ?)',
                [userId, score]
            );
        }

        res.json({ 
            message: 'Score updated successfully',
            data: result,
            operation: existingScore.length > 0 ? 'update' : 'insert'
        });
    } catch (err) {
        console.error('Error updating score:', err);
        res.status(500).json({ error: 'Error updating score' });
    }
});

// Export the router
module.exports = router;
