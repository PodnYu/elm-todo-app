const express = require('express');
const cors = require('cors');

start();

async function start() {
	const PORT = 3000;

	const app = express();

	app.use(express.json());
	app.use(cors());

	app.use((req, res, next) => {
		console.log(req.url, req.body);
		next();
	});

	app.use('/api/v1', router());

	app.listen(PORT, () => console.log(`listening on :${PORT}`));
}

function router() {
	const router = express.Router();

	let todoItems = [];

	router.get('/todos', (_, res) => {
		res.send(todoItems);
	});

	router.get('/todos/:id', (req, res) => {
		const itemId = req.params.id;
		const todo = todoItems.find((i) => i.id === itemId);

		if (!todo) {
			return res.sendStatus(404);
		}

		res.send(todo);
	});

	router.post('/todos', (req, res) => {
		const { title, description } = req.body;

		const newItem = {
			id: Math.floor(Math.random() * 100_000).toString(),
			title,
			description,
			checked: false,
		};

		todoItems.push(newItem);

		res.status(201).send(newItem);
	});

	router.delete('/todos/:id', (req, res) => {
		const itemId = req.params.id;

		if (!todoItems.find((i) => i.id === itemId)) {
			return res.sendStatus(404);
		}

		todoItems = todoItems.filter((i) => i.id !== itemId);

		res.sendStatus(204);
	});

	function setChecked(req, res, checked) {
		const itemId = req.params.id;

		if (!todoItems.find((i) => i.id === itemId)) {
			return res.sendStatus(404);
		}

		todoItems = todoItems.map((i) => (i.id !== itemId ? i : { ...i, checked }));

		res.sendStatus(201);
	}

	router.post('/todos/:id[:]check', (req, res) => setChecked(req, res, true));

	router.post('/todos/:id[:]uncheck', (req, res) =>
		setChecked(req, res, false)
	);

	return router;
}
